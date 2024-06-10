# profiling-使用火焰图分析 #

火焰图(Flame Graph) 也是性能分析的利器。最初是由 Netflix 的 Brendan Gregg 发明并推广的。

X 轴显示的是在该性能指标分析中所占用的资源量，也就是横向越宽，则意味着在该指标中占用的资源越多，Y 轴则是调用栈的深度。

有几点需要注意：左右顺序不重要，X 轴不是按时间顺序发生的，而是按字母顺序排序的；虽然很好看，但是颜色深浅没关系，这是随机选取的。

火焰图可以来自于很多数据源，包括 pprof 和 perf。Uber 提供了火焰图的 Go 的工具，go-torch，在你提供了 /debug/pprof 的情况下，可以自动进行分析处理生成火焰图。

***火焰图中性能问题一般出现在平顶处***

## 1. Go 1.11之前 ##

```
$ go get github.com/uber/go-torch

$ go build -gcflags=-cpuprofile=/tmp/c.p .
$ go-torch $(go tool -n compile) /tmp/c.p
```

## 2. Go 1.11之后 ##

注意，Go 1.11版本之后已经内置了go-torch

As of Go 1.11, flamegraph visualizations are available in go tool pprof directly!

```
# This will listen on :8081 and open a browser.
# Change :8081 to a port of your choice.
$ go tool pprof -http=":8081" [binary] [profile]
```