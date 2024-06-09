# spf13——pflag #

pflag is a drop-in replacement(直接替换) for Go's flag package, implementing POSIX/GNU-style --flags.

> pflag is a drop-in replacement of Go's native flag package. If you import pflag under the name "flag" then all code should continue to function with no changes.There is one exception to this: if you directly instantiate the Flag struct there is one more field "Shorthand" that you will need to set. Most code never instantiates this struct directly, and instead uses functions such as String(), BoolVar(), and Var(), and is therefore unaffected.

https://github.com/spf13/pflag

## Command line flag syntax ##

Commands represent actions, Args are things and Flags are modifiers（修饰语） for those actions.

```
APPNAME COMMAND ARG --FLAG
```

flag的格式中，最后一种格式不能用于bool类型的flag，因为如果有文件名为0、false等的文件会有歧义)

```
--flag=x    //flags without a 'no option default value'
--flag    //flags with no option default values
--flag x  // non-boolean flags
```

* Single dashes signify a series of shorthand letters for flags. 
* Flag parsing stops after the terminator "--". Unlike the flag package, flags can be interspersed with arguments anywhere on the command line before this terminator.
* Integer flags accept 1234, 0664, 0x1234 and may be negative. Boolean flags (in their long form) accept 1, 0, t, f, true, false, TRUE, FALSE, True, False. Duration flags accept any input valid for time.ParseDuration.

## 绑定自定义变量：pflag.Value ##

通过 flag.Var() 绑定自定义类型变量，自定义类型需要实现 Value 接口。如下：(对这种flag，默认值就是该类型变量的初始化值。)

pflag.Value 与 flag.Value 的区别。

flag.Value

```
type Value interface {
        String() string
        Set(string) error
}
```

pflag.Value

```
type Value interface {
        String() string
        Set(string) error
        Type() string
}
```

## shorthands: appending 'P' to the name ##

The pflag package also defines some new functions that are not in flag, that give one-letter shorthands for flags. You can use these by appending 'P' to the name of any function that defines a flag.

```
var flagvar bool
func init() {
    flag.BoolVarP(&flagvar, "boolname", "b", true, "help message")
}
```

## Setting no option default values for flags ##

After you create a flag it is possible to set the pflag.NoOptDefVal for the given flag. Doing this changes the meaning of the flag slightly. If a flag has a NoOptDefVal and the flag is set on the command line without an option the flag will be set to the NoOptDefVal.

 For example given：

```
var ip = flag.IntP("flagname", "f", 1234, "help message")
flag.Lookup("flagname").NoOptDefVal = "4321"
```

Would result in something like


```
//Parsed Arguments	Resulting Value
--flagname=1357	ip=1357
--flagname  		ip=4321
[nothing]   		ip=1234
```

## example ##

```
package main

import (
    "fmt"
    "github.com/spf13/pflag"
)

type Test struct {
    name string
}

func (t *Test) String() string {
    return t.name
}
func (t *Test) Set(s string) error {
    t.name = s
    return nil
}
func (t *Test) Type() string {
    return "hello"
}
func main() {
    l := pflag.IntP("lll", "l", 1, "usage")
    var a int
    var t pflag.Value = &Test{name: "tome"}
    pflag.IntVarP(&a, "abc", "a", 1, "usage")
    pflag.VarP(t, "test", "t", "usage")
    pflag.Parse()
    fmt.Println(*l)
    fmt.Println(a)
    fmt.Println(t)
}

```