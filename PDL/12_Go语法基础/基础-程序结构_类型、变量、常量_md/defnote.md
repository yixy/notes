# 基础-程序结构(类型、变量、常量) #

## 0. 程序实体 ##

在 Go 语言中，程序实体是变量、常量、函数、结构体和接口的统称。程序实体的名字被统称为标识符。标识符可以是任何 Unicode 编码可以表示的字母字符、数字以及下划线“_”，但是其首字母不能是数字。

* 程序实体的作用域：包外可见的、包级私有的、internal package、代码块内可见的

internal package是一个在Go1.5引入的一种特殊的package 定义。对于internal package，只有直接父级package，以及父级package的子孙package可以访问，其他的都不行。当然，引用前需要先导入这个internal包，并且也只能访问internal package使用大写暴露出的内容，小写的不行。对于其他代码包，导入该internal包都是非法的，无法通过编译。

```
#demo3_lib.go里可以访问internal package
tree chapter/
chapter/
└── demo3
    ├── demo3.go
    └── lib
        ├── demo3_lib.go
        └── internal
            └── internal.go
```

## 1. 类型 ##

Golang的基本类型如下。

```
bool

string

int  int8  int16  int32  int64
uint uint8 uint16 uint32 uint64 uintptr

byte // uint8 的别名

rune // int32 的别名
     // 代表一个Unicode码

float32 float64

complex64 complex128
```

int, uint 和 uintptr 在 32 位系统上通常为 32 位宽，在 64 位系统上则为 64 位宽。 当你需要一个整数值时应使用 int 类型，除非你有特殊的理由使用固定大小或无符号的整数类型。

Golang的高级类型包含struct、数组和切片、map、chan、interface、func。

Golang中的类型都是值传递的。

* 基本类型：byte、int、bool、float32、float64、string、指针
* 其他类型：数组、slice、结构体、map、interface、channel、各种func

（Golang中具备引用传递特征的类型实际上也是值传递，其类似引用传递的效果都源于指针：）

* 切片：切片内部有指向数组的指针，可以改变所指向的数组元素。
* map：本质上是一个字典指针。
* channel：和map类似，也是一个指针。
* interface：接口具备引用语义，是因为其内部也维持了两个指针。（指向类型和值）

我们可以用关键字type声明自定义的各种类型。

* 类型别名，MyString是string的别名，两者是相同的类型
* 类型重定义，MyString2和string是两个不同的类型

```
type MyString = string  //类型别名，MyString是string的别名，两者是相同的类型
type MyString2 string    //类型重定义，MyString2和string是两个不同的类型
```

## 2. 变量 ##

var 语句定义了一个变量的列表。通常，变量名在前，类型在后。var语句可以定义在包或函数级别。在函数中，`:=` 简洁赋值语句在明确类型的地方，可以用于替代 var 定义。函数外的每个语句都必须以关键字开始（`var`、`func`等等），`:=` 结构不能使用在函数外。

* 赋值可以在编译时进行自动类型推断
* Golang支持匿名变量和多返回变量，即一个赋值语句中可以对多个变量同时进行赋值

变量的声明方式：

```
#声明类型
var name string
#基于类型推断
var name = "Tom"
#基于类型推断，短变量声明方式（仅在函数体内部可用）
name:="Tom"
```

在定义一个变量但不指定其类型时（使用没有类型的 var 或 := 语句）， 变量的类型由右值推导得出。

```
var a int   //声明方式一
var b=123   //声明方式二：基于Go语言的类型推断再加上一点语法糖

func f() ( c,d string){
  c:="thisisstr" //声明方式三：同样是基于Go语言的类型推断再加上一点语法糖。只能在函数体内部使用
  var d ="ok"
  return
}
```

**Redeclaration** 

对于使用:=定义的变量，如果新变量与那个同名已定义变量 (这里就是1处的变量a)不在一个作用域中时，那么golang会重新定义这个变量。

```
func main() {

    a := 1
    if 1 == 1 {
        a, b := 2, 3
        fmt.Println(a, b)//2,2
    }
    fmt.Println(a)//1
}
```

**reassignment**

err在第一个语句里declare，在第二个语句里仅仅是重新赋值。

```
f, err := os.Open(name)
...
d, err := f.Stat()
```

reassignment发生的条件：

* `:=`与已有声明在同一作用域内（如果已有声明是在外部作用域的, `:=`会在内部作用域重新declare一个变量)
* `:=`右边的value符合预期值
* 至少有一个其他变量被declare

** 零值**

变量在定义时没有明确的初始化时会赋值为"零值"。

* 数值类型为 `0`，
* 布尔类型为 `false`，
* 字符串为 `""`（空字符串）。
* 指针类型为`nil`

## 3 类型转换与类型断言 ##

类型转换方面与其他编程语言的差异：

* 类型转化：Go不允许隐式类型转换。Go 在不同类型之间的赋值是需要显式转换，表达式 T(v) 将值 v 转换为类型 `T`。
* 类型断言：类型断言表达式的语法形式是x.(T)。其中的x代表要被判断类型的那个值。x这个值当下的类型必须是接口类型的，不过具体是哪个接口类型其实是无所谓的。
* 别名和原有类型也不能进行隐式类型转换

Go 语言的类型推断可以明显提升程序的灵活性，使得代码重构变得更加容易，同时又不会给代码的维护带来额外负担（实际上，它恰恰可以避免散弹式的代码修改），更不会损失程序的运行效率。通过这种类型推断，你可以体验到动态类型编程语言所带来的一部分优势，即程序灵活性的明显提升。但在那些编程语言中，这种提升可以说是用程序的可维护性和运行效率换来的。Go 语言是静态类型的，所以一旦在初始化变量时确定了它的类型，之后就不可能再改变。这就避免了在后面维护程序时的一些问题。另外，请记住，这种类型的确定是在编译期完成的，因此不会对程序的运行效率产生任何影响。

如果断言的是非接口类型，怎么办呢？

```
value, ok := interface{}(container).([]string)
```

这里有一条赋值语句。在赋值符号的右边，是一个类型断言表达式。它包括了用来把container变量的值转换为空接口值的interface{}(container)。以及一个用于判断前者的类型是否为切片类型 []string 的 .([]string)。这个表达式的结果可以被赋给两个变量，在这里由value和ok代表。变量ok是布尔（bool）类型的，它将代表类型判断的结果，true或false。如果是true，那么被判断的值将会被自动转换为[]string类型的值，并赋给变量value，否则value将被赋予nil（即“空”）。顺便提一下，这里的ok也可以没有。也就是说，类型断言表达式的结果，可以只被赋给一个变量，在这里是value。但是注意，这样的话，当类型断言表达式判断为否时就会引发异常。


```
package main
import "fmt"
type Person struct {
}
func (p *Person) Speak() {
  fmt.Println("i can speak.")
}
type Tom struct {
}
func main() {
  t := Tom{}
  //Person(t).Speak() //不是可寻址的，所以会Panic
  p := Person(t)
  p.Speak() //If x is addressable and &x's method set contains m, x.m() is shorthand for (&x).m().
}


//output 
i can speak.
```

## 4. 常量 ##

常量的定义与变量类似，只不过使用 const 关键字。常量可以是字符、字符串、布尔或数字类型的值。常量不能使用 := 语法定义。一个未指定类型的常量由上下文来决定其类型。

注意，常量定义时一定要被赋值，如果两个const的赋值语句表达式相同，可以省略后一个赋值表达式。

在Golang中，常量指编译期间就已知且不可改变的值。常量可以是数值类型、布尔类型、字符串类型。Golang的常量是无类型的，即只要该常量在相应类型的值域范围内，就可以作为该类型的常量。

iota可以被认为是一个可被编译器修改的常量，在每个const关键字出现时被重置为0，然后在下一个const出现之前，每出现一次iota，其所代表的数字会自动增1。

iota可以被用来做Golang中实现枚举。
