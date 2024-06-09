# Base64标准库-与Java类库的区别 #

与HTTP头部、Json的处理类似，Golang对Base64解码的处理也更严格一些。无所谓优劣，语言所处的历史时期和设计者所持的角度不同罢了。

## 1. Java的实现 ##

根据base64编码的规则，等号是不会出现在base64格式编码报文的中间的。

对于Java的类库，base64decode函数会将等号后的字符串自动忽略，然后进行解码。

```
5LiOSFRUUOWktOmDqOOAgUpzb27nmoTlpITnkIbnsbvkvLzvvIxHb2xhbmflr7lCYXNlNjTop6PnoIHnmoTlpITnkIbkuZ/mm7TkuKXmoLzkuIDkupvjgILml6DmiYDosJPkvJjliqPvvIzor63oqIDmiYDlpITnmoTljoblj7Lml7bmnJ/lkozorr7orqHogIXmiYDmjIHnmoTop5LluqbkuI3lkIznvaLkuobjgIJlCg==test
```

## 2. Golang ##

Golang标准库当然没有做这种容错处理了，解析上面的字符串会直接报错。