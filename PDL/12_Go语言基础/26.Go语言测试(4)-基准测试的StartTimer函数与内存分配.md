---
categories:
- 云计算
date: "2019-09-28T21:59:14+08:00"
lastmod: "2019-10-02T17:04:22+08:00"
tags:
- 云计算
- Golang
title: Go语言测试(4)-基准测试的StartTimer函数与内存分配
---

## 1. 一次基准测试时发现的诡异问题 ##

测试代码如下，`StringSize`和`StringSizeBySizeTable`两个函数正常应该都是纳秒级别返回的。

```
func BenchmarkStringSize(b *testing.B) {
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        //b.StopTimer()
        u := uint(i)
        //b.StartTimer()
        _ = StringSize(u)
    }
}
func BenchmarkStringSizeBySizeTable(b *testing.B) {
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        //b.StopTimer()
        u := uint(i)
        //b.StartTimer()
        _ = StringSizeBySizeTable(u)
    }
}
```

上面代码中`b.StopTimer()`和`b.StartTimer()`函数被注释掉时，测试结果如下，符合预期：

```
$ go test -v  -run=none -bench=.
goos: darwin
goarch: amd64
pkg: test/intsize
BenchmarkStringSize-4                   123021969                9.91 ns/op
BenchmarkStringSizeBySizeTable-4        151649162                8.16 ns/op
PASS
ok      sweeat.me/test/intsize  5.542s
```

`b.StopTimer()`和`b.StartTimer()`函数没被注释掉时，测试结果如下，严重不符合预期：

```
$ go test -v  -run=none -bench=.
goos: darwin
goarch: amd64
pkg: test/intsize
BenchmarkStringSize-4                    7498533               165 ns/op
BenchmarkStringSizeBySizeTable-4         6614935               176 ns/op
PASS
ok      sweeat.me/test/intsize  634.817s
```

编译器版本：

```
$ go version
go version go1.13 darwin/amd64
```

## 2. 通过pprof进行分析 ##

针对上面第二种情况，为什么启用了`b.StopTimer()`和`b.StartTimer()`函数，会导致测试结果偏差严重，一点头绪都没有。没办法，只能先通过pprof分析工具看看了。

```
go test -v  -run=none -bench=. -cpuprofile=cpu.profile
go tool pprof -http=":8080" intsize.test cpu.profile
```

通过pprof的报告可以明显看到`stopTheWorldWithSema`和`startTheWorld`两个方法执行时间很长，而且这两个方法并不是目标测试代码直接call的，而是runtime下被调起。怀疑与GC有关。开始查阅官方文档及benchmark实现原理。

* `StartTimer()`负责启动计时并初始化内存相关计数，测试执行时会自动调用，一般不需要用户启动。
* `StopTimer()`负责停止计时，并累加相应的统计值。

需要注意，`StopTimer()`并不一定是测试结束，一个测试中有可能有多个统计阶段，所以其统计值是累加的。

特别需要注意，`StartTimer()`负责启动计时，并记录当前内存分配情况，不管是否有`-benchmem`参数，内存都会被统计，参数只决定是否要在结果中输出。

从以上结果进行分析，推测在`StartTimer()`执行时会有内存分配，由于目标测试函数执行时间很短，并且在每次循环中都调用了`StartTimer()`函数，导致Go语言GC发生，影响基准测试结果。而在正常情况下，由于`StartTimer()`函数只在基准测试时被调用一次，则不会产生上面的问题。