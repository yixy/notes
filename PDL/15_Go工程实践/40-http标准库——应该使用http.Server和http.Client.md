# http标准库——应该使用http.Server和http.Client #

http.ListenAndServe, http.ListenAndServeTLS及http.Serveare等经由http.Server的便利函数不太适合用于对外发布网络服务。因为这些函数默认关闭了超时设置，也无法手动设置。使用这些函数，将很快泄露连接，然后耗尽文件描述符。

应该使用http.server和http.Client！在创建http.server实例的时候，调用相应的方法指定ReadTimeout（读取超时时间）和WriteTimeout（写超时时间）

## 1. 设置最后期限(超时) ##

首先，需要理解Go提供的最初级的网络超时实现：Deadlines（最后期限）。

在Go标准库net.Conn中实现了Deadlines，通过 set[Read|Write]Deadline(time.Time)方法进行设置。Deadlines是一个绝对时间，一旦到时，将停止所有I/O操作，并产生一个超时错误。（time.Time的精度是纳秒）

Deadlines本身是不会超时的。一旦被设置，将一直生效（直到再一次调SetDeadline），它并不关心在此期间链接是否存在以及如何使用。因此，http实现中需要在每次进行读/写操作前，使用SetDeadline设定一个超时时长。实际开发中，并不需要直接调用SetDeadline，而是在标准库net/http中使用更高层次的超时设置并且不需要在每次收/发操作前，重置超时。(译注：tcp、udp、unix-socket也是如此，参见标准库net)。

## 2. http.server ##

![golanghttpservertimeout](http://sweeat.me/golanghttpservertimeout.png)

http.Server提供了两个超时实现ReadTimeout和WriteTimeout。你可以使用显式定义方式来设置它们：

```
srv := &http.Server{  
    ReadTimeout: 5 * time.Second,
    WriteTimeout: 10 * time.Second,
}
srv.ListenAndServe()
```

ReadTimeout涵盖的时间范围是：从受理一个链接请求开始，到读取一个完整请求报文后结束（HTTP协议的请求报文，可能只有报文头，例如GET，所以，也可以是读取请求报文头后）。是在net/http的Accept方法中，通过调用SetReadline来设置的。

WriteTimeout涵盖的时间范围是：从读取请求报文头后开始，到返回响应报文后结束（也可以称为：ServeHTTP生命周期）。在readRequest方法结束前，通过SetWriteDeadline来设置。

然而，在使用HTTPS连接时，WriteTimeout是在Accept方法中，调用SetWriteDeadline来设置的。因为，它还需要涵盖TLS握手所用的时间。这意味着（仅在此情况下），在使用HTTPS时，WriteTimeout实际上包括了请求报文的获取/等待时间。

当你处理不可信的客户端以及网络时，应该将两种超时都设置上。以此来避免，一个客户端，因超慢的读/写操作，长时间占用一个链接资源。

最后是http.TimeoutHandler。它不是一个服务器参数，而是处理器（Handler）的包装器，用于限制ServeHTTP调用的最大时长。当达到超时条件时，将缓存响应数据，并发送一个504 Gateway Timeout 。注意，1.6版本存在问题，1.6.2中被修复。

```
package main

import (
    "fmt"
    "io/ioutil"
    "net/http"
    "time"
)

func mock(w http.ResponseWriter, r *http.Request) {
    fmt.Println("HTTP Method:", r.Method)
    var requestHeader string
    for key, values := range r.Header {
        var v string
        for _, value := range values {
            v += value + ";"
        }
        requestHeader += key + "[" + v[:len(v)-1] + "],"
    }
    fmt.Println("HTTP Header:", requestHeader)

    rBody, err := ioutil.ReadAll(r.Body)
    if err != nil {
        fmt.Println("get request body error.", err)
        w.WriteHeader(513)
        _, err := w.Write([]byte("get request body error." + err.Error()))
        if err != nil {
            panic("get request body error.")
        }
        return
    }
    fmt.Println("HTTP Body:", string(rBody))
    fmt.Println("----------")
    time.Sleep(4 * time.Second)
}

func main() {
    //不推荐的server启动方式
    //http.HandleFunc("/mock.do", mockHandler)
    //err := http.ListenAndServe(":8080", nil)
    //if err != nil {
    //  fmt.Println("start serving exception:", err)
    //}
    mux := http.NewServeMux()
    mux.HandleFunc("/mock.do", mock)
    //注册一个带有http server超时配置的handle
    handlerFunc := http.HandlerFunc(mock)
    handler := http.TimeoutHandler(handlerFunc, 2*time.Second, "http server timeout.")
    mux.Handle("/mock_timeout.do", handler)
    srv := &http.Server{
        Addr:         ":8080",
        Handler:      mux,
        ReadTimeout:  10 * time.Second,
        WriteTimeout: 10 * time.Second,
    }
    srv.ListenAndServe()
}
```

## 3. 客户端超时配置 ##

![golanghttpclienttimeout](http://sweeat.me/golanghttpclienttimeout.png)

客户端超时可以很简单，也可以很复杂。但同样重要的是：要防止资源泄漏和阻塞。

最简单的使用超时的方式是http.Client。它涵盖整个交互过程，从发起连接到接收响应报文结束。

```
c := &http.Client{  
    Timeout: 15 * time.Second,
}
resp, err := c.Get("https://blog.filippo.io/")
```

与服务端情况类似，使用http.Get等包级易用函数创建客户端时，也无法设置超时。应用在开放网络环境中，存在很大的风险。

还有其它一些方法，可以让你进行更精细的超时控制：

* net.Dialer.Timeout 限制创建一个TCP连接使用的时间（如果需要一个新的链接）
* http.Transport.TLSHandshakeTimeout 限制TLS握手使用的时间
* http.Transport.ResponseHeaderTimeout 限制读取响应报文头使用的时间
* http.Transport.ExpectContinueTimeout 限制客户端在发送一个包含：100-continue的http报文头后，等待收到一个go-ahead响应报文所用的时间。在1.6中，此设置对HTTP/2无效。（在1.6.2中提供了一个特定的封装DefaultTransport）

```
c := &http.Client{  
    Transport: &Transport{
        Dial: (&net.Dialer{
                Timeout:   30 * time.Second,
                KeepAlive: 30 * time.Second,
        }).Dial,
        TLSHandshakeTimeout:   10 * time.Second,
        ResponseHeaderTimeout: 10 * time.Second,
        ExpectContinueTimeout: 1 * time.Second,
    }
}
```

目前应该尚没有限制发送请求使用时间的机制。目前的解决方案是，在客户端方法返回后，通过time.Timer来个手工控制读取请求信息的时间（参见下面的“如何取消请求”）。

最后，在新的1.7版本中，提供了http.Transport.IdleConnTimeout。它用于控制一个闲置连接在连接池中的保留时间，而不考虑一个客户端请求被阻塞在哪个阶段。

注意，客户端将使用默认的重定向机制。由于http.Transport是一个底层的系统机制，没有重定向概念，因此http.Client.Timeout涵盖了用于重定向花费的时间，而更精细的超时控，可以根据请求的不同，进行定制。

## 参考 ##

原文：[The complete guide to Go net/http timeouts](https://blog.cloudflare.com/the-complete-guide-to-golang-net-http-timeouts/) 译文：[关于 Go 语言 net/http 模块超时的完整指南](https://studygolang.com/articles/9969)