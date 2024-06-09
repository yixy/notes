# 编码规范-effectiveGo #

## 1 代码格式 ##

使用gofmt来格式化代码。

## 2 命名 ##


Golang中通常使用 MixedCaps（大驼峰） or mixedCaps（小驼峰）而不是underscores（下划线）来进行命名。

###### package name 和 exported name ######

包外名称的可见性取决于其 首 字符是否为大写。因此，值得花一点时间讨论 Go 程序中的命名约定。

**package name命名原则**：短小简洁, 便于联想记忆。通常package name使用小写的single-word，不应该使用下划线或驼峰形式（underscores or mixedCaps）。另外，package name 不用担心碰撞重名，因为可以在import的时候使用别名解决。某些情况下package name可以采用base name of its source directory（比如src/encoding/base64 被命名为 "encoding/base64" 而不是 encoding_base64或 encodingBase64）。

**导出名称exported name命名规则**：包的导入器将使用名称来引用其内容，因此包中的导出名称可以使用该事实来避免重复（Use the package structure to help you choose good names.）。比如，bufio包的buffered reader类型，被定义为Reader，而不是BufReader。再举一个例子，新建ring.Ring实例的导出方法，按Go的习惯一般会被命名为NewRing，但由于Ring是该package的唯一导出类型，所以该导出方法被命名为ring.New()。

Name your packages after what they provide, not what they contain.


###### Getter/Setter ######

虽然golang不会自动生成Getter或Setter方法，但是自己是完全可以自行实现的。如果有一个字段owner (lower case, unexported)，其Getter方法通常命名为 Owner() (注意是upper case, exported), 而不是 GetOwner，对应的Setter方法一般命名为 SetOwner()。

```
owner := obj.Owner() 
if owner != user {
     obj.SetOwner(user) 
}
```

###### interface name ######

按照惯例，单一方法interface由方法名称加上 -er后缀或类似修饰来命名以构造代理名词：如Reader、Writer、Formatter、CloseNotifier 等。

call your string-converter method String not ToString.

## 3 Control structure ##

**Indented flow is for errors**：采用如下的方式，无错误的正常流程代码将成为一条直线，而不是成为缩进的代码。

```
f,err:=os.Open(path)
if err!=nil{
        //handle error
}
//do stuff
```

## 4 function ##

**Named result parameters**：虽然不是必要的，但是函数返回值建议都进行命名，增加可读性，简化变量初始化。


