# 基础——面向对象(组合而不是继承) #

## 1. 代码复用：只支持组合 ##

一般采用组合和继承的方式实现代码复用，Golang不支持继承。

当我们使用组合的方式嵌入一个类型，这个类型的方法就变成了外部类型的方法，但是当它被调用时，方法的接受者是内部类型(嵌入类型)，而非外部类型。

```
//一个组合的例子
package main
import "fmt"
type Pet struct {

}
type Dog struct {
    p *Pet
}
func (p *Pet) speak(){
    fmt.Println("xxxxx.")
}
func main(){
    d := new(Dog)
    d.p.speak()
}
```

## 2. 匿名组合 ##

匿名嵌套类型其实也是组合，也称为匿名组合。虽然看起来像是实现了继承，但是这种“继承”实际上没办法实现多态（不能动态绑定，不支持重写），所以这样的方式是没有意义的。

```
package main
import "fmt"
type Pet struct {

}
type Dog struct {
    Pet //匿名嵌套
}
func (p *Pet) speak(){
    fmt.Println("xxxxx.")
}
func main(){
    d := new(Dog)
    d.speak()
}
```
