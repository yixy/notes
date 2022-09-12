# HTTP笔记(2)——常见的首部字段 #

## 1. Content-Type：报文body的媒体类型 ##

Content-Type说明了报文主体body内媒体对象的类型。

注意，application/x-www-form-urlencoded和multipart/form-data这两种body媒体类型，都是浏览器POST提交时原生支持的，而且现阶段标准中原生 <form> 表单也只支持这两种方式（通过 <form> 元素的 enctype 属性指定，默认为 application/x-www-form-urlencoded。其实 enctype 还支持 text/plain，不过用得非常少）。

**1.application/x-www-form-urlencoded**

该种方式下，说明body里提交的数据按照 key1=val1&key2=val2 的方式进行组织，其中要求key 和 val 都进行 URLencode。大部分服务端语言都对这种方式有很好的支持。很多时候，我们用 Ajax 提交数据时，也是使用这种方

```
    POST http://www.example.com HTTP/1.1
    Content-Type: application/x-www-form-urlencoded;charset=utf-8

    %20title%3Dtest%26sub%5B%5D%3D1%26sub%5B%5D%3D2%26sub%5B%5D%3D3
```

注意，除了application/x-www-form-urlencoded类型的包体，其它包体并不要求进行URLencode。

另外，不像 JSON，application/x-www-form-urlencoded 的方式对复杂类型（例如数组）的处理，并没有严格的标准。有的接口使用 key[]=a&key[]=b 来表示数组 key: ['a', 'b']，（这也是最常见的，jQuery、superagent等客户端会如此编码），有的库则将数组编码为：key=a&key=b，有的则是携带下标进行编码：key[0]=a&key[1]=b……十分混乱。所以如果是数组且数组的每一项为简单基本类型，而且非要用 application/x-www-form-urlencoded 进行序列化，那么不如用英文逗号分隔的字符串来表示。如果是嵌套对象……那么还是尽早使用 JSON。

**2.application/json**

application/json用来指明报文主体是序列化后的 JSON 字符串。由于 JSON 规范的流行，除了低版本 IE 之外的各大浏览器都原生支持 JSON.stringify，服务端语言也都有处理 JSON 的函数，使用 JSON 不会遇上什么麻烦。

```
    POST http://www.example.com HTTP/1.1
    Content-Type: application/json;charset=utf-8

    {"title":"test","sub":[1,2,3]}
```

**3.text/xml**

text/xml用来指明报文主体是xml格式。

```
    POST http://www.example.com HTTP/1.1
    Content-Type: text/xml

    <?xml version="1.0"?>
    <methodCall>
    <methodName>examples.getStateName</methodName>
    <params>
        <param>
            <value><i4>41</i4></value>
        </param>
    </params>
    </methodCall>
```

**4.multipart/form-data; boundary =xxxxxx**

该种方式下，指明了数据是 multipart/form-data 类型，并且以 boundary 字符串分隔不同的数据部分。

消息主体分为多个结构类似的部分，每部分都是以 --boundary 开始，紧接着是内容描述信息，然后是空行，最后是字段具体内容（文本或二进制）。如果传输的是文件，还要包含文件名和文件类型信息。消息主体最后以 --boundary-- 标示结束。关于 multipart/form-data 的详细定义，请前往 rfc1867 查看。boundary 用于分割不同的数据内容，为了避免与正文内容重复，boundary 一般很长很复杂。这种方式一般用来上传文件，各大服务端语言对它也有着良好的支持。

```
    POST http://www.example.com HTTP/1.1
    Content-Type:multipart/form-data; boundary=----WebKitFormBoundaryrGKCBY7qhFd3TrwA

    ------WebKitFormBoundaryrGKCBY7qhFd3TrwA
    Content-Disposition: form-data; name="text"

    title
    ------WebKitFormBoundaryrGKCBY7qhFd3TrwA
    Content-Disposition: form-data; name="file"; filename="chrome.png"
    Content-Type: image/png

    PNG ... content of chrome.png ...
    ------WebKitFormBoundaryrGKCBY7qhFd3TrwA--
```

**5.multipart/byteranges; boundary =xxxxxx**

与multipart/form-data类似，在报文主体包含了多个范围内容时使用。

## 2. Content-Encoding：报文body的编码方式 ##

Content-Encoding指明了对body内容的编码方式，指明是否进行了无损压缩，具体方式如下：

* gzip（GNU zip）
* compress（Unix系统标准压缩）
* deflate（zlib）
* identity（不进行编码）

## 3. Connection：管理持久连接/不再转发的首部字段名 ##

Connetion字段有两个作用。

**1.管理持久连接**

HTTP协议一般是建立在TCP协议通信基础之上的。早期HTTP/1.0中，每次HTTP通信（请求响应），都需要在通信前建立TCP连接（三次握手）和通信后释放连接（四次挥手）。这样造成了巨大的通信开销。所以在HTTP/2.0规范中，引入了持久连接（keep-alive）的概念，在HTTP通信过程中，如果没有任何一方明确提出断开连接，则保持TCP连接状态。此时请求方可以持续发送请求，服务方也能连续返回响应。

HTTP/1.0规范中，默认连接都是非持久连接。为此，若想在旧版本HTTP协议上维持持续连接，需要指定：

* Connection：Keep-Alive

HTTP/1.1规范中，默认连接都是持久连接。当服务端想明确端口连接时，需指定：

* Connection：close

**2.控制代理不再转发的首部字段**

通知代理不再转发的首部字段名。例如，客户端请求如下：

    GET / HTTP/1.1
    Upgrade:HTTP/1.1
    Connection:Upgrade

经过代理转发后如下：

    GET / HTTP/1.1

## 4. Content-Length：报文主体body长度 ##

上面介绍了HTTP协议的一个重要概念，即Persistent Connection（持久连接，通俗说法长连接）。通过建立这个概念，客户端重用已经打开的空闲持久连接，可以避开缓慢的三次握手，还可以避免遇上 TCP 慢启动的拥塞适应阶段，听起来十分美妙。但是此时存在一个问题，对于非持久连接，客户端可以通过连接是否关闭来界定请求或响应报文主体的边界；而对于持久连接，这种方法显然是不奏效的。尽管服务端已经发送完所有数据，但客户端并不知道这一点，它无法得知这个打开的连接上是否还会有新数据进来，只能阻塞并等待了。

要解决上面这个问题，最容易想到的办法就是计算报文主体body的长度，并通过头部告诉对方。Content-Length就是用于说明报文主体长度的头部字段。

## 5. Transfer-Encoding：chunked 报文主体分块 ##

由于 Content-Length 字段必须真实反映实体长度，但实际应用中，有些时候实体长度并没那么好获得，例如实体来自于网络文件，或者由动态语言生成。这时候要想准确获取长度，只能开一个足够大的 buffer，等内容全部生成好再计算。但这样做一方面需要更大的内存开销，另一方面也会让客户端等更久。

Transfer-Encoding 正是用来解决上面这个问题的。当在报文头部加入 Transfer-Encoding: chunked 之后，就代表这个报文采用了分块编码。这时，报文中的主体需要改为用一系列分块来传输。每个分块包含十六进制的长度值和数据，长度值独占一行，长度不包括它结尾的 CRLF（\r\n），也不包括分块数据结尾的 CRLF。最后一个分块长度值必须为 0，对应的分块数据没有内容，表示实体结束。

HTTP 1.1引入分块传输编码提供了以下几点好处：

HTTP分块传输编码允许服务器为动态生成的内容维持HTTP持久连接。通常，持久链接需要服务器在开始发送消息体前发送Content-Length消息头字段，但是对于动态生成的内容来说，在内容创建完之前是不可知的。[动态内容，content-length无法预知]
分块传输编码允许服务器在最后发送消息头字段。对于那些头字段值在内容被生成之前无法知道的情形非常重要，例如消息的内容要使用散列进行签名，散列的结果通过HTTP消息头字段进行传输。没有分块传输编码时，服务器必须缓冲内容直到完成后计算头字段的值并在发送内容前发送这些头字段的值。[散列签名，需缓冲完成才能计算]
HTTP服务器有时使用压缩 （gzip或deflate）以缩短传输花费的时间。分块传输编码可以用来分隔压缩对象的多个部分。在这种情况下，块不是分别压缩的，而是整个负载进行压缩，压缩的输出使用本文描述的方案进行分块传输。在压缩的情形中，分块编码有利于一边进行压缩一边发送数据，而不是先完成压缩过程以得知压缩后数据的大小。[gzip压缩，压缩与传输同时进行]


## 6. HTTP中的cookie技术 ##

HTTP是无状态协议，服务器端可以通过cookie技术记录客户端状态数据。

* set-cookie：服务器端第一次响应时携带的首部字段。
* cookie：客户端后续请求时携带的首部字段。


## 7. 参考 ##

《四种常见的 POST 提交数据方式》,Jerry Qu,https://imququ.com/post/four-ways-to-post-data-in-http.html