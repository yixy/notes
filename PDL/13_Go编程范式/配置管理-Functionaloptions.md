# 配置管理-Functionaloptions #

在编程中，我们会经常性的需要对一个对象（或是业务实体）进行相关的配置。针对配置属性较多，且存在可选属性的情况下，如何优雅的实现配置管理是一个问题。

注意，库设计时候的决策，一定要考虑：**如果公共方法越多，package的API表面积越大，那么库越脆弱，因为涉及到兼容性的破坏可能性就更大。**

## 1 各种不同签名的函数实现 ##

因为Go语言不支持重载函数，所以，最直观的方式是用不同的函数名来应对不同的配置选项。但是这无疑加大来API表面积，不利于维护，并且使用也不直观。

## 2 配置对象方案 ##

参考标准库net/http.Server的实现，在new http.Server对象时，通过文档来了解结构体中参数描述，并进行初始化设置。

这样做还是比较晦涩，必输非必输不清楚，过度依赖于文档。

## 3 Functional options ##

首先，先定义一个函数类型：（注意，这里server是小写，这样外部无法使用）

```
type option func(*server) 
```
可以使用函数式的方式定义一组如下的函数：

```
func (s *server) Protocol(p string)  {
        s.Protocol = p
}
func (s *server) Timeout(timeout time.Duration)  {
        s.Timeout = timeout
}
func (s *server) MaxConns(maxconns int)  {
        s.MaxConns = maxconns
}
func (s *server) TLS(tls *tls.Config)  {
        s.TLS = tls
}

```

上面这组代码传入一个参数，然后返回一个函数，返回的这个函数会设置自己的 Server 参数。

再定一个 NewServer()的函数，其中，有一个可变参数 options 其可以传出多个上面上的函数，然后使用一个for-loop来设置我们的 Server 对象。

```
func NewServer(addr string, port int, options ...func(*server)) (*Server, error) {

  srv := Server{
    Addr:     addr,
    Port:     port,
    Protocol: "tcp",
    Timeout:  30 * time.Second,
    MaxConns: 1000,
    TLS:      nil,
  }
  for _, option := range options {
    option(&srv)
  }
  //...
  return &srv, nil
}
```

注意下面这个例子，是另外一种定义方式，这里函数返回了option，是为了方便单元测试用例进行不同场景的切换。

```
type option func(*server) option

func  Protocol(p string) option {
    return func(s *server) option{
        prev:=s.Protocol
        s.Protocol = p
        return Protocol(prev)
}

```

最后思考一个问题，如何将Functional options与配置文件/配置中心/web设置等诸多配置设置方式读取解耦呢？

可以统一创建一个struct结构，并为该struct创建func(*server)Options()方法，该方法用于生成option函数。

## 参考 ##

self-referential functions and the design of options，Rob Pike
Functional options for friendly APIs，Dave Cheney