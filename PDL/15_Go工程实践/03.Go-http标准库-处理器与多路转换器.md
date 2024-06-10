# http标准库——处理器与多路转换器 #

## 1. 处理器Handler与适配器HandlerFunc ##

实现了Handler接口的对象被称为处理器，它可以注册到HTTP服务端，为特定的路径及其子树提供服务。

请求可以从*Request中获取，回复的头域和数据写入ResponseWriter接口然后返回。返回标志着该请求已经结束，HTTP服务端可以转移向该连接上的下一个请求。

```
type Handler interface {
    ServeHTTP(ResponseWriter, *Request)
}
```

HandlerFunc是一个适配器（本质上是一个函数类型，它实现了Handler接口，所以它实际上也是一个处理器），它通过强制类型转换让我们可以将普通的函数作为HTTP处理器使用。如果f是一个具有适当签名的函数，则HandlerFunc(f)类型实现了Handler接口，即它的ServeHTTP方法会调用f(w, r)。

```
type HandlerFunc func(ResponseWriter, *Request)

// ServeHTTP calls f(w, r).
func (f HandlerFunc) ServeHTTP(w ResponseWriter, r *Request) {
    f(w, r)
}
```

## 2. 多路转换器ServeMux ##

ServeMux类型是HTTP请求的多路转接器。它会将每一个接收的请求的URL与一个注册模式的列表进行匹配，并调用和URL最匹配的模式的处理器。

* 本质上ServeMux只是一个路由管理器，而它本身也实现了Handler接口的ServeHTTP方法。因此围绕Handler接口的方法ServeHTTP，可以轻松的写出go中的中间件。

```
type ServeMux struct {
    // 内含隐藏或非导出字段
}

//注册HTTP处理器handler和对应的模式pattern。如果该模式已经注册过处理器，Handle会panic。
func (mux *ServeMux) Handle(pattern string, handler Handler)

// HandleFunc registers the handler function for the given pattern.
func (mux *ServeMux) HandleFunc(pattern string, handler func(ResponseWriter, *Request)) {
    //HandlerFunc(handler)进行强制类型转换
    mux.Handle(pattern, HandlerFunc(handler))
}

//ServeHTTP将请求派遣到与请求的URL最匹配的模式对应的处理器。
func (mux *ServeMux) ServeHTTP(w ResponseWriter, r *Request)
```

> 模式是固定的、由根开始的路径，如"/favicon.ico"，或由根开始的子树，如"/images/"（注意结尾的斜杠）。较长的模式优先于较短的模式，因此如果模式"/images/"和"/images/thumbnails/"都注册了处理器，后一个处理器会用于路径以"/images/thumbnails/"开始的请求，前一个处理器会接收到其余的路径在"/images/"子树下的请求。
> URL结尾是斜线，则匹配其路径下的任何子路径；URL结尾不是斜线表固定资源
最长匹配原则（贪心）
> 注意，因为以斜杠结尾的模式代表一个由根开始的子树，模式"/"会匹配所有的未被其他注册的模式匹配的路径，而不仅仅是路径"/"。
> 模式也能（可选地）以主机名开始，表示只匹配该主机上的路径。指定主机的模式优先于一般的模式，因此一个注册了两个模式"/codesearch"和"codesearch.google.com/"的处理器不会接管目标为"http://www.google.com/"的请求。

Handler根据r.Method、r.Host和r.URL.Path等数据，返回将用于处理该请求的HTTP处理器。它总是返回一个非nil的处理器。如果路径不是它的规范格式，将返回内建的用于重定向到等价的规范路径的处理器。Handler也会返回匹配该请求的的已注册模式；在内建重定向处理器的情况下，pattern会在重定向后进行匹配。如果没有已注册模式可以应用于该请求，本方法将返回一个内建的"404 page not found"处理器和一个空字符串模式。

```
func (mux *ServeMux) Handler(r *Request) (h Handler, pattern string)
```