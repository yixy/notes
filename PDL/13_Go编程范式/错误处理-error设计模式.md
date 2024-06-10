# 错误处理-error设计模式 #

## 1 go的error接口 ##

Go中的error实际上是一个实现了Error()方法的接口。

```
// The error built-in interface type is the conventional interface for
// representing an error condition, with the nil value representing no error.
error types interface {
	Error() string
}
```
**注意，程序中不应依赖检查 error.Error 的输出。**使用Error()返回，进行反序列化后判断错误信息不是一个好的实现方式。不应该依赖检测 error.Error 的输出，Error 方法存在于 error 接口主要用于方便程序员使用，但不是程序 (编写测试可能会依赖这个返回)。这个输出的字符串用于记录日志、输出到 stdout 等。

`errors.New(string)`方法可用于创建error，注意New函数这里返回的是指针类型，这样做是避免后续的等值比较出问题：

```go
package main

import (
	"errors"
	"fmt"
)

type errString string

func (e errString) Error() string {
	return string(e)
}

func New(text string)error {
	return errString(text)
}

var err=New("EOF")
var errPoint=errors.New("EOF")

func main(){

	if err==New("EOF"){
		fmt.Println("err equals")
	}

	if errPoint==errors.New("EOF"){
		fmt.Println("errPoint equals")
	}
}

```

## 2 Error vs Exception ##

各个语言的演进历史：1）C语言是单返回值，一般通过传递指针作为入参，返回值为 int 表示成功还是失败。2）C++引入了 exception，但是无法知道被调用方会抛出什么异常。3）Java引入了 checked exception，方法的所有者必须申明，调用者必须处理。在启动时抛出大量的异常是司空见惯的事情，并在它们的调用堆栈中尽职地记录下来。Java 异常不再是异常，而是变得司空见惯了。它们从良性到灾难性都有使用，异常的严重性由函数的调用者来区分。

Java的异常捕获机制本身是很好的一种机制，但是不同水平的程序员写出代码可能大相径庭，一个常见的问题是将业务处理逻辑写到catch块中（隐藏的控制流）。

Go 的处理异常逻辑是不引入 exception，支持多参数返回，所以你很容易的在函数签名中带上实现了 error interface 的对象，交由调用者来判定。如果一个函数返回了 (value, error)，你不能对这个 value 做任何假设，必须先判定 error。唯一可以忽略 error 的是，如果你连 value 也不关心。Go 中有 panic 的机制，如果你认为和其他语言的 exception 一样，那你就错了。对于真正意外的情况，那些表示不可恢复的程序错误，例如索引越界、不可恢复的环境问题、栈溢出，我们才使用 panic。对于其他的错误情况，我们应该是期望使用 error 来进行判定。

Go的error的特点：

* 简单
* 考虑失败，而不是成功（plan for failure, not success）
* 没有隐藏的控制流
* 完全交给你来控制 error
* Error are values

## 3 不推荐的error模式-SentinelError与error types ##

* sentinel error：对外暴露预定义的特定错误（Sentinel这个名字来源于计算机编程中使用一个特定值来表示不可能进行进一步处理的做法）。对于 Go，我们一般在包级别定义特定的值来表示sentinel error，调用方可以使用 == 将结果与预先声明的值进行比较。
* error types：对外暴露实现了 error 接口的自定义类型。调用者可以使用断言转换成这个类型，来获取更多的上下文信息。

典型的sentinel error模式如 io.EOF，以及更底层的 syscall.ENOENT。

```go
#package io
var EOF = errors.New("EOF")

#package syscall
ENOENT   = Errno(0x2)
......
type Errno uintptr
func (e Errno) Error() string {
	if 0 <= int(e) && int(e) < len(errors) {
		s := errors[e]
		if s != "" {
			return s
		}
	}
	return "errno " + itoa(int(e))
}

```

典型的error types模式，例如 MyError 类型记录了文件和行号以展 示发生了什么。因为 MyError 是一个 type，调用者可以使用断言转换成这个类型，来获取更多的上下文信息。

```go
type MyError struct{
	Msg string
	File string
	Line int
}

func (e *MyError) Error() string {
	return fmt.Sprintf("%s %d : %s",e.File,e.Line,e.Msg)
}

func test()error {
	return &MyError{"err happened","xxx.go",7}
}
func main() {
	err := test()
	switch err := err.(type) {
		case nil:
			fmt.Println("success")
		case *MyError:
			fmt.Println("error in line",err.Line)
		default:
			fmt.Println("unknow error")
	}
}
```

使用 sentinel 值模式是最不灵活的错误处理策略，因为调用方必须使用 == 将结果与预先声明的值进行比较。当想要提供更多的上下文时，这就出现了一个问题，因为返回一个不同的错误将破坏相等性检查。甚至是一些有意义的 fmt.Errorf 携带一些上下文，也会破坏调用者的 == ，调用者将被迫查看 error.Error() 方 法的输出，以查看它是否与特定的字符串匹配。

与sentinel 错误值相比，错误类型error type模式处理策略的一大改进是它们能够包装底层错误以提供更多上下文。

**需要注意，对于sentinel error或type error错误处理模式，公共函数或方法返回一个特定值的错误并且该错误调用方是可感知的，所以该值必须是public的，并且要有文档记录，这会增加API 的表面积**。这个问题最糟糕的地方在于它在两个包之间创建了源代码依赖关系。例如，检查错误是否等于io.EOF，您的代码必须导入 io 包。这个特定的例子听起来并不那么糟糕，因为它非常常见，但是想象一下， 当项目中的许多包导出错误值或类型，存在耦合，项目中的其他包必须导入这些错误值或类型才能检查特定的错误条件(in the form of an import loop)。这样将**导致和调用者产生强耦合，从而导致 API 变得脆弱，包之间的版本兼容性将收到调整**。

所以应该**尽可能避免 sentinel errors和error types错误处理模式（对外暴露sentinel值或错误类型）**。在标准库中有一些使用它们的情况，但这不是一个应该模仿的模式。

## 4 使用不透明的错误处理模式-Opaque errors ##

* Opaque errors模式：只需返回错误而不假设其内容，是最灵活的错误处理策略，因为它要求代码和调用者之间的耦合最少。关于操作的结果，作为调用者所知道的就是它起作用了，或者没有起作用(成功还是失败)。


```go
x,err:=foo.Bar()
if err !=nil{
	return err
}
//use x
```

**Assert errors for behaviour, not type**

少数情况下，如上的二分错误处理方法是不够的。例如，与进程外的世界进行交互(如网络活动)，需要调用方调查错误的性质，以确定重试该操作是否合理。在这种情况下，我们可以断言错误实 现了特定的行为，而不是断言错误是特定的类型或值。这里的关键是，这个逻辑可以在不导入定义错误的包或者实际上不了解 err 的底层类型的情况下实 现——我们只对它的行为感兴趣。这样通过函数来解耦了包之间的强依赖。

```go
type timeoutFlag interface {
	TimeoutFlag() bool
}

func IsTimeoutFlag(err error) bool {
	timeout,ok:=err.(timeoutFlag)
	return ok && timeout.TimeoutFlag()
}

```

## 参考 ##

Don’t just check errors, handle them gracefully, https://dave.cheney.net/2016/04/27/dont-just-check-errors-handle-them-gracefully
