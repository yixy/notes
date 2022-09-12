# HTTP笔记(1)——协议简介（HTTP1.1） #

http是一个应用层协议，用于客户端和服务器端之间进行通信。其中，发起请求访问的一方为客户端，响应资源请求的一方为服务器端。http本身是一种无状态协议。

## 1. HTTP与TCP ##

> “HTTP communication usually takes place over TCP/IP connections. The default port is TCP 80 , but other ports can be used. This does  not preclude HTTP from being implemented on top of any other protocol  on the Internet, or on other networks. HTTP only presumes a reliable  transport; any protocol that provides such guarantees can be used;  the mapping of the HTTP/1.1 request and response structures onto the  transport data units of the protocol in question is outside the scope    of this specification.”——RFC2616

由以上描述可以看出，默认情况下HTTP使用TCP，但是HTTP也可以基于以后存在的其他可靠传输协议。由于UDP无法提供可靠传输，所以一般不会使用UDP。

## 2. HTTP报文格式 ##

用于HTTP协议交互的信息被称为HTTP报文。客户端的HTTP报文通常称为请求报文，服务端的叫做响应报文。HTTP报文本身是由多行数据构成的字符串文本（以CR+LF作为换行符）。

HTTP报文大致可分为报文首部（header）和报文主体（body）两部分，通常使用空行（CR+LF）对两者进行分隔。**注意，报文中的主体不是必须的。**

    ---------------
    |   header    |
    ---------------
    |   CR+LF     |
    ---------------
    |   body      |
    ---------------

一个简单的请求报文如下，它没有body，只有header。header第一行字段分别表示HTTP请求方法，请求URI，以及请求协议版本，它们被用空白字符分隔。

    GET /index.html HTTP/1.1
    Host:localhost

一个简单的响应报文如下，header和body之间通过空行分隔。header第一行分别表示服务端响应协议版本，HTTP状态码，以及状态码原因短语。

    HTTP/1.1 200 OK
    Date: Tue, 10 Dec 2017 07:17:02 GMT
    Content-Length: 1023
    Content-Type: text/html

    <html>
    ...

注意，无论是请求报文还是响应报文，报文首部中除开第一行还有一些字段由name:value方式构成，称为首部字段。比如上面例子中的Host、Date、Content-Length、Content-Type等。若某个首部字段可以有多个值，则格式为name:key1=value1,key2=value2。

## 3. 请求中的HTTP方法 ##

HTTP方法通常是指请求报文首部第一行中的第一个字段，它标明了请求的类型。

HTTP/1.0和HTTP/1.1均支持的方法：

* GET：获取资源。
* POST：传输报文主体（body）。
* PUT：传输文件。通常在请求报文的主体中包含文件内容，保存到请求URI指定的位置。应用需要自行实现验证机制。
* DELETE：删除文件。是与PUT相反的方法，也需要应用自行实现验证机制。
* HEAD：与GET类似，不过不返回主体部分。主要用于确认URI有效性及资源更新时间。

HTTP/1.1协议新增的方法：

* OPTIONS：用于查询针对请求URI指定的资源支持的方法。
* TRACE：用于追踪路径。请求首部中携带Max-Forwards字段，每经过一个代理或网关服务器，该字段值减1，该请求直到Max-Forwards值为0或到达目标端才被服务器接收，此时接收端将接收到的请求头作为响应主体反传给客户端。因为存在XST（cross site tracing）攻击风险，该方法一般被禁用。
* CONNECT：要求在与代理服务器通信时建立隧道，实现用隧道进行TCP通信。主要使用SSL和TLS协议把通信内容加密后经网络隧道传输。

HTTP/1.0中存在，但是在HTTP/1.1中废弃的方法：

* LINK：建立和资源之间的联系
* UNLINK：断开和资源之间的联系

关于GET和POST，再做如下补充说明：

对于GET方式的请求，大多数浏览器会把http header和data一并发送出去，服务器响应200（返回数据）。而对于POST，浏览器先发送header，服务器响应100 continue，浏览器再发送data，服务器响应200 ok（返回数据）。但实际上，并不是所有浏览器都会在POST中发送两次包，Firefox就只发送一次。

## 4. 响应中的状态码 ##

HTTP状态码通常是指响应报文首部第一行的第二个字段。借助状态码，客户端可以知道服务端到底是成功处理了请求还是出现了错误。状态码由3位数字组成，数字第一位指定了响应类别。

* 1xx：信息性状态码。例如，接收的请求正在处理。
* 2xx：成功状态码。
* 3xx：重定向状态码。
* 4xx：客户端错误状态码。例如，服务器无法处理请求。
* 5xx：服务器错误状态码。例如，服务器处理请求出错。

## 5. 首部字段 ##

无论是请求报文还是响应报文，报文首部中除开第一行还有一些字段由name:value方式构成，称为首部字段。若某个首部字段可以有多个值，则格式为name:key1=value1,key2=value2。HTTP首部（header）中字段若有重复，这种情况在规范内尚未明确，其处理逻辑取决于具体的程序实现。

**1.HTTP/1.1规范定义的47种首部字段，RFC2616**

一般通用首部字段，请求报文或响应报文中都可能使用的通用首部字段。

* Cache-Control：控制缓存的行为。
* Connection：逐跳首部、连接的管理。
* Date：创建报文的日期时间。
* Pragma：报文指令。
* Trailer：报文末端的首部一览。
* Transfer-Encoding：指定报文主体的传输编码方式。
* Upgrade：升级为其它协议
* Via：代理服务器的相关信息
* Warning：错误通知

* Allow：资源可支持的HTTP方法
* Content-Encoding：报文主体适用的编码方式
* Content-Language：报文主体的自然语言
* Content-Length：报文主体的大小
* Content-Location：替代对应资源的URI
* Content-MD5：报文主体的报文摘要
* Content-Range：报文主体的位置范围
* Content-Type：报文主体的媒体类型
* Expires：报文主体过期的日期时间
* Last-Modified：资源的最后修改日期时间

请求首部字段，只在请求报文中可能使用的首部字段。

* Accept：用户代理可处理的媒体类型，即客户端希望接收的媒体类型
* Accept-Charset：优先的字符集
* Content-Encoding：优先的内容编码
* Content-Language：优先的语言
* Authorization：Web认证信息
* Expect：期待服务器的特定行为
* From：用户的电子邮箱地址
* Host：请求资源所在服务器
* If-Match：比较实体标记(ETag)
* If-Modified-Since：比较资源的更新时间
* If-None-Match：比较实体标记(与If-Match相反)
* If-Range：资源未更新时发送实体Byte的范围请求
* If-Unmodified-Since：比较资源的更新时间(与If-Modified-Since相反)
* Max-Forwards：最大传输逐跳数
* Proxy-Authorization：代理服务器要求客户端的认证信息
* Range：实体的字节范围请求
* Referer：对请求中URI的原始获取方
* TE：传输编码的优先级
* User-Agent：HTTP客户端程序的信息

响应首部字段，只在响应报文中可能使用的首部字段。

* Accept-Ranges：是否接受字节范围请求
* Age：推算资源创建经过时间
* Etag：资源的匹配信息
* Location：令客户端重定向至指定URI
* Proxy-Authenticate：代理服务器对客户端的认证信息
* Retry-After：对再次发起请求的时机要求
* Server：HTTP服务器的安装信息
* Vary：代理服务器缓存的管理信息
* WWW-Authenticate：服务器对客户端的认证信息

**2.其它首部字段，RFC4229**

在HTTP协议通信交互中使用到的首部字段，不限于RFC2616中定义的47种首部字段。还有Cookie、Set-Cookie和Content-Disposition等在其它RFC中定义的首部字段，他们的使用频率也很高。

* cookie
* set-cookie
* Content-Disposition

**分类：End-to-end首部与Hop-by-hop首部**

* End-to-end首部：此类别中的首部会转发给请求/响应对应的最终接收目标，且必须保存在由缓存生成的响应中，另外规定它必须被转发。
* Hop-by-hop首部：此类别的首部只对单次转发有效，会因通过缓存或代理而不再转发。HTTP/1.1和之后的版本中，如果要使用Hop-by-hop首部，需提供Connection首部字段。

下面列举了HTTP/1.1中的Hop-by-hop首部字段，除了这8个首部字段之外，其它所有字段均属于End-to-end首部字段。

* Conncetion
* Keep-Alive
* Proxy-Authenticate
* Proxy-Authorization
* Trailer
* TE
* Transfer-Encoding
* Upgrade


