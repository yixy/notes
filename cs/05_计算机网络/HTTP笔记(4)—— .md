# HTTP笔记(4)—— #

首先并行是靠多连接的，不过HTTP协议规定单个客户端对相同域名的并发连接是受限的，以前是两个，所以诞生了把资源放在不同域名下的优化技术。那就假设一个连接好了，同时发起10个请求，则必须一个个处理，没有KeepAlive的话，每个请求结束后都会关闭TCP连接，下一个请求需要重新连接。有KeepAlive后连接不关闭，下个请求复用该连接。






这个时候有一个问题就来了，我们为什么不在 一个socket上连续发送多个request。原因是因为HTTP1.1 及更低版本的协议，并没有一个字段用来区分一个response是归属于哪一个request的。但HTTP 2 就有这个字段了。因此在HTTP1.1 及更低版本，你只能在发送一个request之后，等待response的到来。
直到今日，应用最广泛的依然是HTTP1.1 协议,这就造成了目前浏览器都是并行加载的,是的都是并行的。
HTTP1.1 request和response 的无标识符问题(即response无法指明是哪一个request的)，就造就了现在这种情况。HTTP 2 协议解除了这个问题。

现代浏览器就是并行连接的。
现在的浏览器基本上都会在适合的适合并行加载资源的。
keep-alive和并行连接没有直接的关系。
一个是说连接保持长时间后才关闭，一个是说同时发多条连接，互不影响的。



keeplive：tcp open--->request1--->response1--->request2--->response2...--->tcp close并行：tcp open--->request1--->response1--->tcp close同时tcp open--->request2--->response2--->tcp close...tcp open--->requestN--->responseN--->tcp closepipeline:tcp open--->request1--->request2...--->requestN--->response1--->response2...--->responseN--->tcp closehttp 0.9和http 1.0时代：tcp open--->request1--->response1--->tcp close完成后                                                                           tcp open--->request2--->response2--->tcp close



HTTP/1.1 对 HTTP/1.0 做了许多优化，也是当今使用得最多的 HTTP 协议：
持久化连接以支持连接重用
分块传输编码以支持流式响应
请求管道以支持并行请求处理
字节服务以支持基于范围的资源请求
改进的更好的缓存机制

https://linjunzhu.github.io/blog/2016/03/10/http2-zongjie/

HTTP2采用多路复用是指，在同一个域名下，开启一个TCP的connection，每个请求以stream的方式传输，每个stream有唯一标识，connection一旦建立，后续的请求都可以复用这个connection并且可以同时发送，server端可以根据stream的唯一标识来相应对应的请求。


多路复用使用的同一个TCP的connection会关闭么，什么时候关闭，这是个问题？从标准上看到一段文字：
HTTP/2 connections are persistent. For best performance, it is
expected that clients will not close connections until it is
determined that no further communication with a server is necessary
(for example, when a user navigates away from a particular web page)
or until the server closes the connection.

意思就是说关闭的时机有2个：
1）用户离开这个页面。
2）server主动关闭connection。
但是标准总归标准，不同的服务器实现时有了自己的约定，就行keep alive一样，每种服务器都有对自己多路复用的这个connection有相关的配置