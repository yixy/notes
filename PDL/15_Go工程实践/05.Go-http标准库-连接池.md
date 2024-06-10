# http标准库——连接池与maxIdleConnsPerHost配置 # 需要好好分析下http包

使用net/http包的http.Client和http.Server做http调用实验时发现，压力测试情况下QPS很低，并且系统CPU的占用周期性冲高。分析发现，user CPU和sys CPU出现交替增长，并且，进程运行期间上下文切换频繁。另外，通过netstat命令查看，客户端存在大量TIME_WAIT的连接记录。

* net/http默认为长连接，可以通过在客户端设置request.Close=true声明短连接。

```
// 在服务端指定是否在回复请求后关闭连接，在客户端指定是否在发送请求后关闭连接。
http.Request.Close bool

// Close记录头域是否指定应在读取完主体后关闭连接。（即Connection头）
// 该值是给客户端的建议，Response.Write方法的ReadResponse函数都不会关闭连接。
http.Response.Close bool
```

## 问题原因 ##

Transport类型实现了RoundTripper接口，支持http、https和http/https代理。Transport类型可以缓存连接以在未来重用。Transport是协程安全的。

Transport默认定义如下：

```
// DefaultTransport is the default implementation of Transport and is  
// used by DefaultClient. It establishes network connections as needed  
// and caches them for reuse by subsequent calls. It uses HTTP proxies  
// as directed by the $HTTP_PROXY and $NO_PROXY (or $http_proxy and  
// $no_proxy) environment variables.  
var DefaultTransport RoundTripper = &Transport{
    Proxy: ProxyFromEnvironment,  
    DialContext: (&net.Dialer{  
        Timeout:   30 * time.Second,  //拨号超时时间
        KeepAlive: 30 * time.Second,  //默认开启长连接，持续30s
        DualStack: true,  
    }).DialContext,  
    MaxIdleConns:          100,  //最大空闲连接处
    IdleConnTimeout:       90 * time.Second,  //连接最大空闲时间，超过这个时间就会被关闭。
    TLSHandshakeTimeout:   10 * time.Second,  //限制TLS握手使用的时间
    ExpectContinueTimeout: 1 * time.Second,  //限制client在发送包含 Expect: 100-continue的header到收到继续发送body的response之间的时间等待。注意在1.6中设置这个值会禁用HTTP/2(DefaultTransport自1.6.2起是个特例)
}
```

可以看到默认最大连接数MaxIdleConns是100。

![golanghttpclientconnpoolget](http://sweeat.me/golanghttpclientconnpoolget.svg)

![golanghttpclientconnpoolput](http://sweeat.me/golanghttpclientconnpoolput.svg)

继续分析Transport中相关处理代码发现，当获取一个IdleConn处理完request后，会调用tryPutIdleConn方法回放conn，此时代码有这样一个逻辑：

```
idles := t.idleConn[key]  
if len(idles) >= t.maxIdleConnsPerHost() {  
    return errTooManyIdleHost  
}
```

MaxIdleConnsPerHost限制的是相同connectMethodKey的空闲连接数量
DefaultMaxIdleConnsPerHost的默认值是2，这对一个大并发的场景是完全不够用的。

也就是说IdleConn不仅受到MaxIdleConn的限制，也受到MaxIdleConnsPerHost的限制，DefaultTranspor中是没有设置该参数的，而默认的参数为2。由于压力测试时使用的目标服务器为单节点上的挡板程序，所以实际上压测场景是为server to server的定点访问。调整该参数后，性能问题得到解决。

## 3. 参考 ##

http://oohcode.com/2018/06/01/golang-http-client-connection-pool/

[go HTTP Client大量长连接保持(自定义client设置及源码简单分析)](http://blog.csdn.net/kdpujie/article/details/73177179)

[Golang 优化之路——HTTP长连接](http://blog.cyeam.com/golang/2017/05/31/go-http-keepalive)
