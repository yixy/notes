# 基础——程序结构(表达式、语句) #

golang的`if`和`for`语句中的条件表达式不需要使用圆括号。

* golang的循环只支持for关键字

`if`和`for`语句可以在条件之前执行一个简单的语句。由这个语句定义的变量的作用域仅在`if`或`for`的范围之内。

for循环的这三个部分每个都可以省略。

```
for initialization; condition; post {
    // zero or more statements
}
```

for循环的另一种形式, 在某种数据类型的区间（range）上遍历，如字符串、切片和map。

```
for _ , arg := range os.Args[1:] {
    s += sep + arg
    sep = " "
}
```

switch 的条件从上到下的执行，当匹配成功的时候停止。没有条件的 switch 同 `switch true` 一样，这一构造使得可以用更清晰的形式来编写长的 if-then-else 链。

* 条件表达式不限制为常数或整数
* 单case中，可以出现多个结果选项，用逗号分隔
* Go不像C一样需要用break来明确退出一个case
* 可以不设定switch之后的条件表达式，这种情况下与多个if else的逻辑作用等同

```
switch time.Saturday {
case today + 0:
  fmt.Println("Today.")
case today + 1:
  fmt.Println("Tomorrow.")
case today + 2:
  fmt.Println("In two days.")
default:
  fmt.Println("Too far away.")
}
```

Go语言不需要在语句或者声明的末尾添加分号，除非一行上有多条语句。实际上，编译器会主动把特定符号后的换行符转换为分号, 因此换行符添加的位置会影响Go代码的正确解析。比如行末是标识符、整数、浮点数、虚数、字符或字符串文字、关键字break、continue、fallthrough或return中的一个、运算符和分隔符++、--、)、]或}中的一个。

和其他编程语言在自增自减上的区别：

* go没有前置的++和--
* go的i++和i--是语句而不是表达式

自增语句i++给i加1；这和i += 1以及i = i + 1都是等价的。对应的还有i--给i减1。注意，自增和自减是语句，而不是表达式，而不像C系的其它语言那样是表达式。所以j = i++非法，而且++和--都只能放在变量名后面，因此--i也非法。

