# context标准库 #

在 Go http 包的 Server 中，每一个请求在都有一个对应的goroutine去处理。请求处理函数通常会启动额外的goroutine用来访问后端服务，比如数据库和 RPC 服务。用来处理一个请求的goroutine通常需要访问一些与请求特定的数据，比如终端用户的身份认证信息、验证相关的 token、请求的截止时间。当一个请求被取消或超时时，所有用来处理该请求的goroutine都应该迅速退出，然后系统才能释放这些goroutine占用的资源。

这样的一个请求链可以看做是一棵树。如果是叶子结点要取消，是很好实现的，但如果是非叶子结点，则还需要同步取消它的孩子。Go的context标准库就是用来方便做这些处理的。

![context管理任务的取消](http://sweeat.me/context管理任务的取消.png)

> 注意：go1.6及之前版本请使用golang.org/x/net/context。go1.7及之后已移到标准库context。

## 1. context原理 ##

* 根context：通过context.Backgroud()创建
* 子context：ctx,cancel:=context.WithCancel(parentContext)创建。
* 当前context的cancel方法被调用时，基于他的子context的cancel方法都会被调用
* ctx.Done()返回一个channel，用于监听ctx.cancel()

> Go语言context标准库的Context类型提供了一个Done()方法，该方法返回一个类型为 <-chan struct{}的channel。每次context收到取消事件后这个channel都会接收到一个struct{}类型的值。所以在Go语言里监听取消事件就是等待接收<-ctx.Done()。

Context 的调用是链式的，通过WithCancel，WithDeadline，WithTimeout或WithValue派生出新的 Context。当父 Context 被取消时，其派生的所有 Context 都将取消。

通过context.WithXXX都将返回新的 Context 和 CancelFunc。调用 CancelFunc 将取消子代，移除父代对子代的引用，并且停止所有定时器。未能调用 CancelFunc 将泄漏子代，直到父代被取消或定时器触发。go vet工具检查所有流程控制路径上使用 CancelFuncs。

遵循以下规则，以保持包之间的接口一致，并启用静态分析工具以检查上下文传播。

1. 不要将 Contexts 放入结构体，相反context应该作为第一个参数传入，命名为ctx。 func DoSomething（ctx context.Context，arg Arg）error { // ... use ctx ... }  【当把上下文存储在一个结构中时，会向调用者隐藏它的生命周期，甚至可能的是把两个不同的作用域以不可预料的方式互相干扰】
2. 即使函数允许，也不要传入nil的 Context。如果不知道用哪种 Context，可以使用context.TODO()。
3. 使用context的Value相关方法只应该用于在程序和接口中传递的和请求相关的元数据，不要用它来传递一些可选的参数
4. 相同的 Context 可以传递给在不同的goroutine；Context 本身是并发安全的。但需要注意，保证Value相关方法对应但数据是协程并发安全的。

> A Context is safe for simultaneous use by multiple goroutines. Code can pass a single Context to any number of goroutines and cancel that Context to signal all of them.Value allows a Context to carry request-scoped data. That data must be safe for simultaneous use by multiple goroutines.

## 2 context的争议 ##

如果你从没接触过 Golang，那么按其它编程语言的经验来推测，多半会认为 Context 是用来读写一些请求级别的公共数据的，事实上 Context 也确实拥有这样的功能：

```
Value(key interface{}) interface{}
WithValue(parent Context, key, val interface{}) Context
```

不过除此之外，Context 还有一个功能是控制 goroutine 的退出：

```
func WithCancel(parent Context) (ctx Context, cancel CancelFunc)
func WithDeadline(parent Context, d time.Time) (Context, CancelFunc)
func WithTimeout(parent Context, timeout time.Duration) (Context, CancelFunc)
```

把两个毫不相干的功能合并在同一个包里，无疑增加了使用者的困扰。Dave Cheney 曾经吐槽：「Context isn’t for cancellation https://dave.cheney.net/2017/08/20/context-isnt-for-cancellation」，按他的观点：Context 只应该用来读写一些请求级别的公共数据，而不应该用来控制 goroutine 的退出，况且用 Context 来控制 goroutine 的退出，在功能上并不完整（没有确认机制），原文：

> Context‘s most important facility, broadcasting a cancellation signal, is incomplete as there is no way to wait for the signal to be acknowledged.

此外，Michal Štrba 的观点更为尖锐，按他的观点「Context should go away for Go 2 https://faiface.github.io/post/context-should-go-away-go2/」：用 Context 来读写一些请求级别的公共数据，本身就是一种拙劣的设计；而用 Context 来控制 goroutine 退出亦如此，正确的做法应该是在语言层面解决，不过关于这一点，只能寄希望于 Golang 2.0 能有所作为了。

从目前社区对 Context 的使用情况来看，基本上主要还是使用 Context 控制 goroutine 的退出，不管你喜不喜欢，Context 已经成为了一种事实标准。

## 参考 ##

https://m.vlambda.com/wz_KGYfLs5KZ.html