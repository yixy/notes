# 基础——携程机制 #

## 1. Thread vs Goroutine ##

创建时默认的stack：

* JDK5以后的JavaThreadStack默认为1M
* Groutine的stack初始化大小为2k

和KSE（Kernel Space Entity）的对应关系（KSE可以认为是内核线程）：

* Java Thread是1:1
* Groutine是M:N

## 2. goroutine ##

Go程序从初始化main package并执行main()函数开始，当main()函数返回时，程序退出，且程序并不等待其他goroutine（非主goroutine）结束。

> 一般的，执行一个函数时通常会等待函数的结果返回。但是开启goroutine时，goroutine只管执行，并且是和主goroutine分开执行，并不会等待结果返回，这是基本的构成思想。

**每次在程序中使用 go 关键字启动 goroutine 时，都必须知道该 goroutine 将如何退出以及何时退出。如果你不知道答案，那就是潜在的内存泄漏。**

## 3 参考 ##

Goroutine相关内容参考Go的runtime。