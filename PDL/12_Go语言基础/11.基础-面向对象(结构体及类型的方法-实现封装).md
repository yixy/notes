# 基础——面向对象(结构体及类型的方法-实现封装) #

## 0. 非典型的面向对象支持 ##

Golang并没有直接沿袭C++和Java的传统去设计一个超级复杂的类型系统，Go不支持继承和重写，而只是支持了最基本的类型组合功能。

## 1. 数据的封装：结构体 ##

一个结构体（`struct`）就是一些字段的集合。

结构体文法表示通过结构体字段的值作为列表来新分配一个结构体。使用 Name: 语法可以仅列出部分字段。（字段名的顺序无关。）特殊的前缀 & 返回一个指向结构体的指针。

注意，一个命名为S的结构体类型将不能再包含S类型的成员：因为一个聚合的值不能包含它自身。（该限制同样适应于数组。）但是S类型的结构体可以包含*S指针类型的成员，这可以让我们创建递归的数据结构，比如链表和树结构等。

首字母小写的结构体字段被看作是内部隐藏字段。结构体的字段可以使用点号来访问。

```
type Vertex struct {
    X, Y int
}

var (
    v1 = Vertex{1, 2}  // 类型为 Vertex
    v2 = Vertex{X: 1}  // Y:0 被省略
    v3 = Vertex{}      // X:0 和 Y:0
    p  = &Vertex{1, 2} // 类型为 *Vertex
)

func main() {
    fmt.Println(v1, p, v2, v3)
    //{1 2} &{1 2} {1 0} {0 0}
}
```

可以使用结构体来实现抽象封装。

## 2. 行为的封装：类型的方法 ##

Go 没有类。然而，仍然可以在类型上定义方法。方法接收者 出现在 func 关键字和方法名之间的参数中。类型（比如结构体）的方法可以使用点号来访问。

***但是注意，不能对来自其他包的类型或基础类型定义方法。***

```
//通过type定义新类型Integer，能够变相实现int类型添加方法
package main
import "fmt"

func main(){
    var i Integer=0
    j:=i.f()
    fmt.Println(j)
}

type Integer int

func (a Integer) f () (int){
    return 1
}
```

## 3 类型方法的一些TIPS ##

* ***[TIPS1]***接收器类型可以是（几乎）任何类型，但是接收器不能是一个接口类型。接收器也不能是一个指针类型，但是它可以是任何其他允许类型的指针。（实际上，这样看起来是不允许多重指针作为receiver）

接收器类型可以是（几乎）任何类型，但是接收器不能是一个接口类型。

> 因为接口是一个抽象定义，而方法却是具体实现，如果这样做了就会引发一个编译错误invalid receiver type。

接收器也不能是一个指针类型，但是它可以是任何其他允许类型的指针。（实际上，这样看起来是不允许多重指针作为receiver）

> 一个类型加上它的方法等价于面向对象中的一个类，一个重要的区别是，在Go语言中，类型的代码和绑定在它上面的方法的代码可以不放置在一起，它们可以存在不同的源文件中，唯一的要求是它们必须是同一个包的。

* ***[TIPS2]***非指针非接口类型的方法调用时，其接收器和形参都会进行值拷贝
* ***[TIPS3]***指向某个非指针非接口类型的指针上定义的方法能够避免值拷贝（虽然仍是值传递，但是传递的是指针的值）。

例子1：

```
package main
import "fmt"
type Student struct {
    name string
}
func (s Student) speak() {
    fmt.Println("My name is " + s.name)
}

//结构体的方法调用时会有值拷贝
func (s Student) setName1() {
    s.name = "Tom"
}
//指向结构体的指针上定义的方法调用时能够避免值拷贝
func (s *Student) setName2() {
    s.name = "Jerry"
}
func main() {
    var s Student = Student{name: "NONE"}
    s.setName1()
    s.speak()
    s.setName2()
    s.speak()
}

```

例子2：


```
package main
  
import (
        "fmt"
        "time"
)

type field struct {
        name string
}

func (p *field) print() {
        fmt.Println(p.name)
}

func main() {
        data1 := []*field{{"one"}, {"two"}, {"three"}}
        for _, v := range data1 {
                go v.print()	//实际是值拷贝，go (*field).print(v)
        }

        data2 := []field{{"four"}, {"five"}, {"six"}}
        for _, v := range data2 {
                go v.print()	 //传递了指针，go (*field).print(&v)
        }
 
        time.Sleep(3 * time.Second)
}
```


* ***[TIPS4]***如果非指针非接口类型的x具有x.m()方法，则指向该类型的指针上使用点号(&x).m()也能访问对应结构体的字段和方法。（所以常常使用指针类型作为参数传递，可以减少拷贝，并且使用形式一样是点号访问）
* ***[TIPS5]***如果非指针非接口类型的x是可寻址的，且x的指针类型有m方法，则x.m()也是合法的，此时它是(&x).m()的简写形式。A method call x.m() is valid if the method set of (the type of) x contains m and the argument list can be assigned to the parameter list of m. If x is addressable and &x's method set contains m, x.m() is shorthand for (&x).m().
* ***[TIPS6]***非指针非接口类型不能同时具有 func (x X) f() 和 func (x *X) f()两个方法，因为编译器会认为f()被重复定义了

> the method set of a type T consists of all methods with receiver type T, while that of the corresponding pointer type *T consists of all methods with receiver *T or T. That means the method set of *T includes that of T, but not the reverse.

> 什么是可寻址的（addressable）：The operand must be addressable, that is, either a variable, pointer indirection, or slice indexing operation; or a field selector of an addressable struct operand; or an array indexing operation of an addressable array. As an exception to the addressability requirement, x [in the expression of &x] may also be a (possibly parenthesized) composite literal.

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
    //Person(t).Speak() //不可寻址，所以会panic
    p := Person(t)
    p.Speak()
}
```


## 4. 说明TIPS的例子 ##

```
package main

import "fmt"

type Pet interface {
    speak()
}

type Dog struct {
}

func (d Dog) speak() {
    fmt.Println("wang")
}

type Cat struct {
}

func (c *Cat) speak() {
    fmt.Println("miu")
}

func main() {
    d := Dog{}
    d.speak()    //Dog类型的方法
    (&d).speak() //指针可以访问其指向类型的方法
    dp := &Dog{}
    dp.speak() //指针可以访问其指向类型的方法
    var p Pet = d
    p.speak() //符合接口定义实现了speak函数
    p = &d
    p.speak() //符合接口定义实现了speak函数
    p = dp
    p.speak() //符合接口定义实现了speak函数

    c := Cat{}
    c.speak()    //此时是(&c).speak()方法调用的简写，c本身并没有实现speak方法
    (&c).speak() //*Cat类型的方法
    cp := &Cat{}
    cp.speak() //*Cat类型的方法
    //p = c
    //p.speak() //此时是(&c).speak()方法调用的简写，c本身并没有实现speak方法
    p = &c
    p.speak() //符合接口定义实现了speak函数
    p = cp
    p.speak() //符合接口定义实现了speak函数
}
```

## 4. receiver或函数参数什么时候应该定义为指针 ##

```
func (s *MyStruct) pointerMethod() { } // method on pointer 
func (s MyStruct)  valueMethod()   { } // method on value
```

对于不习惯指针的程序员来说，这两个例子之间的区别可能会令人困惑，但情况其实很简单。当 定义 一个类型的方法时，receiver 的行为就像它是方法的参数一样。“将receiver 定义为值还是指针”，和“函数参数应该是值还是指针”实际上是同一个问题。对此，一般从几个方面考虑。

* 首先，也是最重要的，该方法是否需要修改接收器？如果是，则接收者必须是一个指针。（切片和map本身包含指针，所以它们的故事有点微妙，但例如要在方法中更改切片的长度，接收者仍然必须是指针。）
* 其次，是对效率的考虑。如果接收器很大，例如一个很大的结构，使用指针接收器代价会小很多。
* 再者是一致性。如果该类型的某些方法必须有指针接收器，其余的也应该如此，因此无论如何使用该类型，方法集都是一致的。
* 最后，对于诸如基本类型、切片和小型结构之类的类型，值接收器代价很小，因此除非该方法的语义需要指针，否则值接收器非常清晰明了。