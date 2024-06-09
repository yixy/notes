# Http.Client与域名解析 #


## Dial ##

`golang`的`httpclient`调用`func Dial(network, address string) (Conn, error)`函数去创建一个连接。

conn, err := net.Dial("tcp", "192.168.0.10:2100")

目前Dial函数支持如下协议：“tcp”、“tcp4用于IPv4”、“tcp6仅限IPv6”、“udp”、“dup4”、“udp6”、“ip”、“ip4”、“ip6”。连接成功后写数据用conn的Writer()成员，接收数据用Read()方法。Dial()函数是对DialTCP()、DIaoUDP、DialIP、DialUnix的封装，这些函数也可以直接使用。实际上dial.go这个文件中并没有实际发起连接的部分，基本上是在为真正发起连接做一系列的准备，比如：解析网络类型、从addr解析ip地址。。。实际发起连接的函数在`tcpsock_posix.go`、`udpsock_posix.go`。

Dial方法里使用了`net.Dialer`。

```
type Dialer struct {
    Timeout time.Duration  //连接超时
    Deadline time.Time
    LocalAddr Addr //真正dial时的本地地址，兼容各种类型(TCP、UDP...),如果为nil，则系统自动选择一个地址
    // DualStack previously enabled RFC 6555 Fast Fallback
    // support, also known as "Happy Eyeballs", in which IPv4 is
    // tried soon if IPv6 appears to be misconfigured and
    // hanging.
    //
    // Deprecated: Fast Fallback is enabled by default. To
    // disable, set FallbackDelay to a negative value.
    DualStack bool // Go 1.2

    // FallbackDelay specifies the length of time to wait before
    // spawning a RFC 6555 Fast Fallback connection. That is, this
    // is the amount of time to wait for IPv6 to succeed before
    // assuming that IPv6 is misconfigured and falling back to
    // IPv4.
    //
    // If zero, a default delay of 300ms is used.
    // A negative value disables Fast Fallback support.
    FallbackDelay time.Duration // Go 1.5
    KeepAlive time.Duration
    Resolver *Resolver     //DNS解析器
    Cancel <-chan struct{}
    Control func(network, address string, c syscall.RawConn) error
}

func (d *Dialer) DialContext(ctx context.Context, network, address string) (Conn, error)
```

Dialer里有一个DialContext方法，它先使用`Resolver *Resolver`解析DNS，然后在创建连接。`Resolver *Resolver`是一个struct，不是个interface

```
type Resolver struct {
    PreferGo bool
    StrictErrors bool
    Dial func(ctx context.Context, network, address string) (Conn, error) //创建到nameserver的连接
}
```

关于双栈支持，参考https://github.com/golang/go/issues/18422。由于http的Client中使用Dial时传参写死为tcp，所以双栈兼容支持只能选用FallbackDelay参数配置（DualStack应该是Go1.5之前的参数，Go1.5之后FastFallBack默认开启，通过FallbackDelay配置）。


## DNS 缓存 ##

通过net.Dial或者net.DialContext去创建连接，或者使用Resolver去解析DNS时，都是没有缓存的。这个意思就是说你每创建一个连接，Resolver都回去解析一次。