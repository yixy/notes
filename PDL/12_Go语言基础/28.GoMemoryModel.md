# Go的内存模型（MemoryModel） #


基于Go的Memory Model的讨论，给出的建议如下：

修改多个 goroutine 同时访问的数据的程序必须序列化（serialize）这种访问。要序列化（serialize）访问，请使用通道操作或其他同步原语（例如 sync 和 sync/atomic 包中的原语）保护数据。（Programs that modify data being simultaneously accessed by multiple goroutines must serialize such access.To serialize access, protect the data with channel operations or other synchronization primitives such as those in the sync and sync/atomic packages.）

## 1. happens before条件 ##

Go内存模型为什么要指定这些条件呢？

编译器或处理器不保证指令执行顺序和程序书写顺序一致。

在单个 goroutine 中，读取和写入的行为必须按照程序所指定的指令执行顺序来执行。也就是说，只有当重新排序不会改变语言规范所定义的 goroutine 中的行为时，编译器和处理器才可以重新排序在单个 goroutine 中执行的读取和写入。由于这种重新排序，一个 goroutine 观察到的执行顺序可能与另一个 goroutine 感知的顺序不同。例如，如果一个 goroutine 执行 a = 1; b = 2;，另一个可能会在 a 的更新值之前观察到 b 的更新值。




happens-before是一个术语，用于定义在程序中执行内存操作的偏序。happens-before并不仅仅是Go语言才有的。简单的说，通常的定义如下：

If event e1 happens before event e2, then we say that e2 happens after e1.Also, if e1 does not happen before e2 and does not happen after e2, then we say that e1 and e2 happen concurrently.



## ##

问：在Go语言中有哪些可以建立happens before关系的同步事件。

答：

包初始化 init函数。

如果一个包 p 导入了包 q，那么 q 的 init 函数完成happens before p 的 init 。main.main 函数的开始happens after 所有的 init 函数完成。

创建goroutine

创建goroutine happens before goroutine执行

销毁goroutine

goroutine执行happens before goroutine的销毁

channel

对channel的关闭先行发生于接收到0值，因为channel已经被关闭了。
2. 无缓冲channel的接收先行发生于发送完成。

3. 在容量为C的channel上的第k个接收先行发生于从这个channel上的第k+C次发送完成。

锁

对任意的sync.Mutex或sync.RWMutex变量l和n < m，n次调用l.Unlock()先行发生于m次l.Lock()返回
2. 对于sync.RWMutex变量l，任意的函数调用l.RLock满足第n次l.RLock后发生于第n次调用l.Unlock，对应的l.RUnlock先行发生于第n+1次调用l.Lock

Once

对于 f() 的单个调用在所有的 once.Do(f) 返回之前发生。

## ##

https://en.m.wikipedia.org/wiki/Java_memory_model
https://en.m.wikipedia.org/wiki/Memory_model_(programming)
https://zhuanlan.zhihu.com/p/58164064