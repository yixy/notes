# profiling-使用pprof分析 #

性能分析不是没有开销的。虽然性能分析对程序的影响并不严重，但是毕竟有影响，特别是内存分析的时候增加采样率的情况。大多数工具甚至直接就不允许你同时开启多个性能分析工具。如果你同时开启了多个性能分析工具，那很有可能会出现他们互相观察对方的开销从而导致你的分析结果彻底失去意义。

所以，一次只分析一个东西。

## 1. profile是如何工作的 ##

profile就是定时采样，收集cpu，内存等信息，进而给出性能优化指导，golang 官方提供了golang自己的性能分析工具的用法。

Profile 会启动你的程序，然后通过配置操作系统，来定期中断程序，然后进行采样。比如发送 SIGPROF 信号给被分析的进程，这样进程就会被暂停，然后切换到 Profile中进行分析。Profile则取得被分析的程序的每个线程的当前位置等信息进行统计，然后恢复程序继续执行。

profiling 可用于识别昂贵的或经常调用的代码段。 Go 运行时以 pprof 可视化工具预期的格式提供 profiling 数据。 profiling 数据可以在测试期间通过 go test 或 net/http/pprof 包中提供的endpoint收集。用户需要收集 profiling 数据并使用 pprof 工具来筛选和可视化顶级代码路径。

## 2. pprof ##

pprof 源自 Google Performance Tools 工具集。Go runtime 中内置了 pprof 的性能分析功能。

* profile(cpu): CPU profile determines where a program spends its time while actively consuming CPU cycles (as opposed to while sleeping or waiting for I/O).
* heap: Heap profile reports memory allocation samples; used to monitor current and historical memory usage, and to check for memory leaks.
* threadcreate: Thread creation profile reports the sections of the program that lead the creation of new OS threads.
* goroutine: Goroutine profile reports the stack traces of all current goroutines.
* block: Block profile shows where goroutines block waiting on synchronization primitives (including timer channels). Block profile is not enabled by default; use runtime.SetBlockProfileRate to enable it.
* mutex: Mutex profile reports the lock contentions. When you think your CPU is not fully utilized due to a mutex contention, use this profile. Mutex profile is not enabled by default, see runtime.SetMutexProfileFraction to enable it.
* allocs:  A sampling of all past memory allocations
* cmdline:  The command line invocation of the current program
* trace:  A trace of execution of the current program. You can specify the duration in the seconds GET parameter. After you get the trace file, use the go tool trace command to investigate the trace.

> 首先net trace区别于runtime trace，net trace用户服务端请求追踪，可以用来展示单次请求后服务端统计和长期执行的程序中的event统计，这些统计都是开发者埋点自己打印进去的。而runtime trace记录的所有的运行时事件，用户诊断性能问题时（如延迟，并行化和竞争异常等）。

What other pro$lers can I use to profile Go programs? 

On Linux, perf tools can be used for proCling Go programs. Perf can profile and unwind cgo/SWIG code and kernel, so it can be useful to get insights into native/kernel performance bottlenecks. On macOS, Instruments suite can be used profile Go programs.

**CPU 性能分析**

最常用的就是 CPU 性能分析，当 CPU 性能分析启用后，Go runtime 会每 10ms 就暂停一下，记录当前运行的 Go routine 的调用堆栈及相关数据。当性能分析数据保存到硬盘后，我们就可以分析代码中的热点了。

一个函数如果出现在数据中的次数越多，就越说明这个函数调用栈占用了更多的运行时间。

**内存性能分析**

内存性能分析则是在堆(Heap)分配的时候，记录一下调用堆栈。默认情况下，是每 1000 次分配，取样一次，这个数值可以改变。

栈(Stack)分配 由于会随时释放，因此不会被内存分析所记录。

由于内存分析是取样方式，并且也因为其记录的是分配内存，而不是使用内存。因此使用内存性能分析工具来准确判断程序具体的内存使用是比较困难的。

**阻塞性能分析**

阻塞分析是一个很独特的分析。它有点儿类似于 CPU 性能分析，但是它所记录的是 goroutine 等待资源所花的时间。

阻塞分析对分析程序并发瓶颈非常有帮助。阻塞性能分析可以显示出什么时候出现了大批的 goroutine 被阻塞了。阻塞包括：

* 发送、接受无缓冲的 channel；
* 发送给一个满缓冲的 channel，或者从一个空缓冲的 channel 接收；
* 试图获取已被另一个 go routine 锁定的 sync.Mutex 的锁；

注意，阻塞性能分析是特殊的分析工具，在排除 CPU 和内存瓶颈前，不应该用它来分析。

另外，获取的 Profiling 数据是动态的，要想获得有效的数据，请保证应用处于较大的负载（比如正在生成中运行的服务，或者通过其他工具模拟访问压力）。否则如果应用处于空闲状态，得到的结果可能没有任何意义。

使用pprof步骤如下：

1. 生成profile文件。对于如何生成这些profile文件有三种办法，使用testing包，使用 runtime/pprof包，或使用net/http/pprof 包。
2. 使用 go tool pprof 来分析profile性能数据文件。注意，pprof 始终需要两个参数，前者必须指向生成这个性能分析数据的那个二进制可执行文件，后者必须是该二进制可执行文件所生成的性能分析数据文件。可以在交互模式下执行 web 命令，这样会生成一个 svg 文件，然后用浏览器或者其它工具打开。(svg依赖Graphviz)

## 3. 生成profile文件-使用testing包对函数进行分析 ##

最简单的对一个函数进行性能分析的办法就是使用 testing 包对测试函数进行性能分析。testing 包内置支持生成 CPU、内存、阻塞的性能分析数据。

* -cpuprofile=xxxx： 生成 CPU 性能分析数据，并写入文件 xxxx；
* -memprofile=xxxx： 生成 内存 性能分析数据，并写入文件 xxxx；
* -memprofilerate=N：调整内存性能分析采样率为 1/N；
* -blockprofile=xxxx： 生成 阻塞 性能分析数据，并写入文件 xxxx；

```
#-run和-bench采用正则，表明不执行功能测试，执行所有基准测试
go test -run=^$ -bench=. -cpuprofile=sample.profile sample
go tool pprof sample.test sample.profile
```

## 4. 生成profile文件-使用runtime/pprof包 ##

testing 适用于分析具体某个函数，但是如果想分析整个应用，则可以使用 runtime/pprof 包。

pprof 封装了很好的接口供我们使用，比如要想进行 CPU Profiling，可以调用 pprof.StartCPUProfile() 方法，它会对当前应用程序进行 CPU profiling，并写入到提供的参数中（w io.Writer），要停止调用 StopCPUProfile() 即可。

去除错误处理只需要三行内容，一般把部分内容写在 main.go 文件中，应用程序启动之后就开始执行：

```
f, err := os.Create(*cpuprofile)
...
pprof.StartCPUProfile(f)
defer pprof.StopCPUProfile()
```

应用执行结束后，就会生成一个文件，保存了我们的 CPU profiling 数据。

想要获得内存的数据，直接使用 WriteHeapProfile 就行，不用 start 和 stop 这两个步骤了：

```
f, err := os.Create(*memprofile)
pprof.WriteHeapProfile(f)
f.Close()
```

## 5. 生成profile文件-使用net/http/pprof包 ##

pprof 适合在开发的时候进行分析，从运行到结束。但是如果应用已经在数据中心运行，我们希望远程启用调试进行在线分析，这种情况，可以通过 http 远程调试。如果你的应用是一直运行的，比如 web 应用，那么可以使用 net/http/pprof 库，它能够在提供 HTTP 服务进行分析。

如果使用了默认的 http.DefaultServeMux（通常是代码直接使用 http.ListenAndServe("0.0.0.0:8000", nil)），只需要添加一行：

```
import _ "net/http/pprof"
```

如果你使用自定义的 Mux，则需要手动注册一些路由规则：

```
r.HandleFunc("/debug/pprof/", pprof.Index)
r.HandleFunc("/debug/pprof/cmdline", pprof.Cmdline)
r.HandleFunc("/debug/pprof/profile", pprof.Profile)
r.HandleFunc("/debug/pprof/symbol", pprof.Symbol)
r.HandleFunc("/debug/pprof/trace", pprof.Trace)
```

不管哪种方式，你的 HTTP 服务都会多出 /debug/pprof endpoint，访问它会得到类似下面的内容：

```
/debug/pprof/

profiles:
0    block
62    goroutine
444    heap
30    threadcreate

full goroutine stack dump
```

这个路径下还有几个子页面：

* /debug/pprof/profile：访问这个链接会自动进行 CPU profiling，持续 30s，并生成一个文件供下载
* /debug/pprof/heap： Memory Profiling 的路径，访问这个链接会得到一个内存 Profiling 结果的文件
* /debug/pprof/block：block Profiling 的路径
* /debug/pprof/goroutines：运行的 goroutines 列表，以及调用关系

然后使用 pprof 工具来查看一段 30秒 的：

CPU 性能分析数据：

```
go tool pprof http://localhost:3999/debug/pprof/profile
```

内存性能分析数据：

```
go tool pprof http://localhost:3999/debug/pprof/heap
```

在 /debug/pprof/heap 页面的最下方，是 runtime.MemStats，这是你的应用真实使用内存的情况（不仅仅是分配）。其中的 HeapSys 是应用从系统申请到的页面数量。

阻塞性能分析数据：

```
go tool pprof http://localhost:3999/debug/pprof/block
```

runtime的trace信息分析：

```
curl http://127.0.0.1:6060/debug/pprof/trace?seconds=20 > trace.out
go tool trace trace.out
```