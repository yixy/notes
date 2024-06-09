# build耗时-使用time命令分析 #

## 1. shell 内置的 time ##

最简单的性能测试工具就是 shell 中内置的 time 命令，这是由 POSIX.2 (IEEE Std 1003.2-1992) 标准定义的，因此所有 Unix/Linux 都有这个内置命令。

```
$ time go fmt github.com/docker/machine
real    0m0.110s
user    0m0.056s
sys     0m0.040s
```

这是使用shell内置的 time来对 go fmt github.com/docker/machine 的命令进行性能分析。

这里一共有3项指标：

* real：从程序开始到结束，实际度过的时间；
* user：程序在用户态度过的时间；
* sys：程序在内核态度过的时间。

一般情况下 real >= user + sys，因为系统还有其它进程。

## 2. GNU 实现的 time ##

除此以外，对于 Linux 系统，还有一套 GNU 的 time，位于 /usr/bin/time，需要用完整路径去调用，不过这个功能就更强大了。

```
vagrant@vagrant:~$ /usr/bin/time -v go fmt github.com/docker/machine
        Command being timed: "go fmt github.com/docker/machine"
        User time (seconds): 0.02
        System time (seconds): 0.06
        Percent of CPU this job got: 85%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:00.09
        Average shared text size (kbytes): 0
        Average unshared data size (kbytes): 0
        Average stack size (kbytes): 0
        Average total size (kbytes): 0
        Maximum resident set size (kbytes): 18556
        Average resident set size (kbytes): 0
        Major (requiring I/O) page faults: 0
        Minor (reclaiming a frame) page faults: 9925
        Voluntary context switches: 430
        Involuntary context switches: 121
        Swaps: 0
        File system inputs: 0
        File system outputs: 32
        Socket messages sent: 0
        Socket messages received: 0
        Signals delivered: 0
        Page size (bytes): 4096
        Exit status: 0
```

可以看到这里的功能要强大多了，除了之前的信息外，还包括了：

CPU占用率；
内存使用情况；
Page Fault 情况；
进程切换情况；
文件系统IO；
Socket 使用情况；
……

## 3. BSD、macOS 的 time ##

BSD 也有自己实现的 time，功能稍逊，但也比 Shell 里的 time 强大。比如 macOS 中继承自 FreeBSD 的 time：

```
$ /usr/bin/time -l go fmt github.com/docker/machine
        0.70 real         0.05 user         0.40 sys
  11710464  maximum resident set size
         0  average shared memory size
         0  average unshared data size
         0  average unshared stack size
      8579  page reclaims
      2571  page faults
         0  swaps
         0  block input operations
         0  block output operations
         0  messages sent
         0  messages received
         3  signals received
      1118  voluntary context switches
      1702  involuntary context switches
```

这里有：内存使用情况、Page Fault 情况、IO 情况、进程切换情况、Signal 情况……

## 4. go tool 中的 -toolexec 参数 ##

当我们构建很慢的时候，如何才能知道为什么慢呢？go 工具链中支持 -x 命令，可以显示具体执行的每一条命令，这样我们就可以看到到底执行到哪里的时候慢了。

```
$ go build -x fmt
WORK=/var/folders/wc/9tzsn1hd7c38tvc54kctn4100000gn/T/go-build846067626
mkdir -p $WORK/runtime/internal/sys/_obj/
mkdir -p $WORK/runtime/internal/
cd /usr/local/Cellar/go/1.9.1/libexec/src/runtime/internal/sys
/usr/local/Cellar/go/1.9.1/libexec/pkg/tool/darwin_amd64/compile -o $WORK/runtime/internal/sys.a -trimpath $WORK -goversion go1.9.1 -p runtime/internal/sys -std -+ -complete -buildid 2749cc50ea3a4ebcf
...
```

但是如果构建时间很长，或者是计划在 CI 中运行，我们就不可能一直盯着了。当然，我们可以时候从输出中复制粘贴到命令行，前缀上 time，也可以知道每个命令的执行时间。不过这太繁琐了。

go tool 工具链中，还支持一个叫做 -toolexec 的参数，其值将作为工具链每一个命令的前缀来执行。换句话说，如果 -toolexec=time，那么假如有一个 go build xxx.go 的命令，就会变为 time go build xxx.go 来执行。

```
$ go build -toolexec="/usr/bin/time" cmd/compile/internal/gc
# runtime/internal/sys
        0.09 real         0.01 user         0.02 sys
# runtime/internal/atomic
        0.01 real         0.00 user         0.00 sys
# runtime/internal/atomic
        0.02 real         0.00 user         0.00 sys
# runtime
        1.60 real         1.90 user         0.12 sys
# runtime
        0.00 real         0.00 user         0.00 sys
# runtime
        0.02 real         0.01 user         0.00 sys
# runtime
        0.01 real         0.00 user         0.00 sys
# runtime
        0.00 real         0.00 user         0.00 sys
...
```

用好了，这就可以变得很强大，不仅仅是计时。比如，我们 go build 的时候我们可以在 Mac 或者 Linux 上进行交叉编译，但是 go test 的时候，我们希望则在手机设备上直接运行。另外，也可以用来校验输出结果的一致性 （toolstash）

## 参考 ##

视频笔记：7种 Go 程序性能分析方法 - Dave Cheney
