# flag标准库 #

flag用于命令行的flag参数解析。

命令行的基本结构如下：


```
APPNAME COMMAND ARG --FLAG

// COMMAND 和 ARG 可以省略， eg.
kubectl -h
kubectl get -h
```

## 1. flag注册 ##

通过 flag.Xxx() 方法返回一个相应的指针。例如，可以使用flag.String(), Bool(), Int()等函数注册flag，下例声明了一个整数flag，返回*int指针：

```
//函数签名内容：name defaultvalue usage
var ip = flag.Int("flagname", 1234, "help message for flagname")
```

通过 flag.XxxVar() 方法将 flag 绑定到一个基础类型变量，该种方式注册绑定的是一个值类型。使用Var系列函数：

```
var flagvar int
flag.IntVar(&flagvar, "flagname", 1234, "help message for flagname")
```

通过 flag.Var() 绑定自定义类型变量，自定义类型需要实现 Value 接口。如下：(对这种flag，默认值就是该类型变量的初始化值。)

```
type Value interface {
        String() string
        Set(string) error
}
```

```
var flagvar Mystruct
flag.Var(&flagVal, "name", "help message for flagname")
```

## 2. flag解析 ##

在所有flag都注册之后，调用：

```
flag.Parse()
```

来根据注册的name信息解析命令行传人参数写入注册的flag里。

## 3. flag使用 ##

解析之后，flag的值可以直接使用。如果你使用的是flag自身，它们是指针；如果你绑定到了某个变量，它们是值。

```
fmt.Println("ip has value ", *ip)
fmt.Println("flagvar has value ", flagvar)
```

解析后，flag后面的参数可以从flag.Args()里获取或用flag.Arg(i)单独获取。这些参数的索引为从0到flag.NArg()-1。

命令行flag语法：(最后一种格式不能用于bool类型的flag，因为如果有文件名为0、false等)

```
-flag
-flag=x
-flag x  // 只有非bool类型的flag可以
```

Flag解析在第一个非flag参数（单个"-"不是flag参数）之前停止，或者在终止符"--"之后停止。

整数flag接受1234、0664、0x1234等类型，也可以是负数。bool类型flag可以是：

```
1, 0, t, f, T, F, true, false, TRUE, FALSE, True, False
```

时间段flag接受任何合法的可提供给time.ParseDuration的输入。

## spf13/pflag ##

POSIX/GNU-style --flags

https://github.com/spf13/pflag