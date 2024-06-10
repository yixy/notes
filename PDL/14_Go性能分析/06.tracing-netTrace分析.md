# tracing-netTrace分析 #

tracing是一种检测代码以分析调用链整个生命周期中的延迟的方法。 Go 提供 `golang.org/x/net/trace` 包作为每个 Go 节点的最小跟踪后端，并提供一个带有简单仪表板的最小检测库。 Go 还提供了一个执行跟踪器来跟踪时间间隔内的运行时事件。

> 首先net trace区别于runtime trace，net trace用户服务端请求追踪，可以用来展示单次请求后服务端统计和长期执行的程序中的event统计，这些统计都是开发者埋点自己打印进去的。而runtime trace记录的所有的运行时事件，用户诊断性能问题时（如延迟，并行化和竞争异常等）。

参考[golang.org/x/net/trace](https://pkg.go.dev/golang.org/x/net/trace)
