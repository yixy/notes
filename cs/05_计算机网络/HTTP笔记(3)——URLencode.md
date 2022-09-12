# HTTP笔记(3)——URLencode #

## 1. RFC 3986 #

一般来说，URL只能使用英文字母、阿拉伯数字和某些标点符号，不能使用其他文字和符号。这是因为网络标准RFC 3986 做了如下规定：

* URI所允许的字符分为保留字符与未保留字符。
* 保留字符是那些具有特殊含义的字符。例如, 斜线字符用于URL (或者更一般的, URI)不同部分的分界符。保留字符包括 ! *   '   (   )   ;   :   @   &   =   +   $   ,   /   ?   #   [   ]等。如果一个保留字符在特定上下文中具有特殊含义(称作"reserved purpose") , 且URI中必须使用该字符用于其它目的, 那么该字符必须百分号编码。
* 未保留字符没有这些特殊含义。未保留字符包括字母数字[0-9a-zA-Z]、和一些特殊符号如 -   _   .   ~ 等，它们可以不经过编码直接用于URL。
* 其它不属于保留或非保留的字符如果要做URI中使用，则必须用百分号编码。
* 百分号编码，首先需要把该字符的ASCII的值表示为两个16进制的数字，然后在其前面放置转义字符("%")，置入URI中的相应位置。(对于非ASCII字符, 需要转换为UTF-8字节序, 然后每个字节按照上述方式表示。)
* 由于百分号字符("%")表示百分号编码字节流的存在, 因此百分号字符应该被编码为3个字节的序列："%25"，用于URI内部。
* 理论上，两个URI的差别如果仅在于未保留字符是用百分号编码还是用字符自身表示，那么这两个URI具有等价的语义。但应用程序实际上并不总是把二者视作等价，这取决于具体的实现。

2005年1月发布的RFC 3986，强制所有新的URI必须对未保留字符不加以百分号编码；其它字符要先转换为UTF-8字节序列, 然后对其字节值使用百分号编码。此前的URI不受此标准的影响。

有一些不符合标准的把Unicode字符在URI中表示为: %uxxxx, 其中xxxx是用4个十六进制数字表示的Unicode的码位值。任何RFC都没有这样的字符表示方法，并且已经被W3C拒绝。

## 2. 表单application/x-www-form-urlencoded类型 ##

当HTML表单中的数据被提交时，这里的编码方法采用了一个非常早期的通用的URI百分号编码方法，它把空格编码为加号"+"，而如果字符本身就是加号"+"，则应该被编码成%2B。而按照RFC-3986规范，空格被编码成%20，而加号"+"被编码成%2B。

HTML表单的这种编码方法当前仍用于（虽然非常过时了）HTML与XForms规范中. 此外，CGI规范包括了web服务器如何解码这类数据、利用这类数据的内容。

注意，浏览器中的表单application/x-www-form-urlencoded提交，默认是做了urlEncode的。

## 3. Java中的URLencode ##

 Java中常用的URL编码类有两个：一个是JDK自带的java.net.URLEncoder,另一个是Apache的org.apache.commons.codec.net.URLCodec。这两个类遵循的都是HTML4标准，即将空格编码成加号"+",代码如下：

```
//输出：%E4%BD%A0+%E5%A5%BD
System.out.println(java.net.URLEncoder.encode("你 好", "utf-8"));

URLCodec en = new URLCodec("utf-8");
//输出：%E4%BD%A0+%E5%A5%BD
System.out.println(en.encode("你 好"));
```

其实要将HTML4的编码结果转换成RFC-3986编码，方法很简单：

```
java.net.URLEncoder.encode("你 好", "utf-8").replaceAll("\\+", "%20");
```

另外Netty中有一个QueryStringEncoder类可以可以实现RFC-3986的URL编码，代码如下：

```
QueryStringEncoder encoder = new QueryStringEncoder("/");
encoder.addParam("name", "开源+中国 博客");
//输出：/?name=%E5%BC%80%E6%BA%90%2B%E4%B8%AD%E5%9B%BD%20%E5%8D%9A%E5%AE%A2
System.out.println(encoder.toUri());
```

## 4. JS中的URLencode ##

escape unescape 已经废弃，应当避免使用。

```
escape 
unescape
```

encodeURI 应当用于整个 URI 的编码，encodeURIComponent 应当用于 URI 中某个部分的编码。

```
//encodeURI 
//decodeURI
//encodeURIComponent 
//decodeURIComponent
encodeURI('https://www.google.com/ a b c')
// "https://www.google.com/%20a%20b%20c"
encodeURIComponent('https://www.google.com/ a b c')
// "https%3A%2F%2Fwww.google.com%2F%20a%20b%20c"
```

其余可参考

> escape,encodeURI,encodeURIComponent有什么区别? - 黑猫的回答 - 知乎 https://www.zhihu.com/question/21861899/answer/43480575

## 5. Golang中的URLencode ##

QueryEscape函数会将空格编码成'+'。QueryUnescape函数将'+'改为' '。

http server在解析URI时使用了ParseRequestURI函数。

QueryUnescape和ParseRequestURI在底层都调用了net/url的同一个函数unescape，仅仅是传入参数不同。QueryUnescape使用了encodeQueryComponent参数，而ParseRequestURI使用了encodePath参数。在unescape函数中：

```
case '+':                                                                  
    if mode == encodeQueryComponent {                                      
        t[j] = ' '                                                         
    } else {                                                               
        t[j] = '+'                                                         
    }
```