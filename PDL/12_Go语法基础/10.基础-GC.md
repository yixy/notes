# 基础——GC #

Go语言的自动圾收集器是如何知道一个变量是何时可以被回收的呢？这里我们可以避开完整的技术细节，基本的实现思路是，从每个包级的变量和每个当前运行函数的每一个局部变量开始，通过指针或引用的访问路径遍历，是否可以找到该变量。如果不存在这样的访问路径，那么说明该变量是不可达的，也就是说它是否存在并不会影响程序后续的计算结果。
因为一个变量的有效周期只取决于是否可达，因此一个循环迭代内部的局部变量的生命周期可能超出其局部作用域。同时，局部变量可能在函数返回之后依然存在。
编译器会自动选择在栈上还是在堆上分配局部变量的存储空间，但可能令人惊讶的是，这个选择并不是由用var还是new声明变量的方式决定的。

## 1. 使用GODEBUG分析GC ##

可以通过在go run 或 go test前使用GODEBUG=gctrace=1来输出GC信息。

```
GODEBUG=gctrace=1 go run main.go
GODEBUG=gctrace=1 go test main.go
```

![golang-gc](http://sweeat.me/golang-gc.png)

## 2. 使用trace分析 ##

go test中的trace参数可以用于分析GC，也可以分析processor的状况。

```
//测试程序输出trace信息
go test -trace trace.out

//可视化trace信息
go tool trace trace.out
```

可以通过在源码中调用API的方式，生成更细粒度的trace文件。

```
trace.Start
trace.Stop
```

## 3. GC友好的代码 ##

* 复杂对象尽量传递其指针，如数组、结构体等
* 自动扩容是有代价的，如slice，应初始化至合适大小
* 复用内存


## 参考 ##

https://godoc.org/runtime

参考Goruntime。