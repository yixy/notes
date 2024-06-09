# http标准库——头部与MIME标准 #

## 1. MIME标准 ##

MIME是对传统电子邮件的一个扩展，现在已经成为电子邮件实际上的标准。

* MIME：Multipurpose Internet Mail Extensions"，多用途互联网邮件扩展。指的是一系列的电子邮件技术规范，主要包括RFC 2045、RFC 2046、RFC 2047、RFC 4288、RFC 4289和RFC 2077。

HTTP头部中的Content-Type字段就来源于MIME，表明信息类型。

MIME标准规定规范化的头部key形式是以"-"为分隔符，每一部分都是首字母大写，其他字母小写。例如"accept-encoding" 的标准化形式是 "Accept-Encoding"。

## 2. CanonicalMIMEHeaderKey ##

Golang的HTTP包中使用了CanonicalMIMEHeaderKey函数，该函数返回一个MIME头的键的规范格式。该标准会将首字母和所有"-"之后的字符改为大写，其余字母改为小写。举个例子，"accept-encoding"作为键的标准格式是"Accept-Encoding"。MIME头的键必须是ASCII码构成。

```
#reader.go
func (h MIMEHeader) Set(key, value string) {
    h[CanonicalMIMEHeaderKey(key)] = []string{value}
}
```

1）reader.go中定义了isTokenTable数组，如果key的长度大于127或者包含不在isTokenTable中的字符，则该key不会被处理。

2）将key的首字母大写，字符 - 后的单词的首字母也大写。

## 参考 ##

《MIME笔记》，阮一峰，http://www.ruanyifeng.com/blog/2008/06/mime.html