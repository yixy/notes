---
categories:
- 云计算
date: "2019-09-30T22:16:33+08:00"
lastmod: "2019-10-02T17:04:22+08:00"
tags:
- 云计算
- Golang
title: Go语言测试(2)-使用mock测试
---

## 1。 使用接口作为参数，使用官方gomock ##

golang原生单元测试的方法就是尽量使用接口作为参数（函数接收一个 interface类型的参数，而不是一种具体的实现类型），尽量不引入比较heavy的测试框架。

gomock是Golang的官方mock工具，主要包含两个部分：gomock库 和 辅助代码生成工具mockgen 。

```
go get github.com/golang/mock/gomock
go install github.com/golang/mock/mockgen
```

下面以一个简单的例子说明gomock的使用。

```
type Animal interface {
    GetName() string
}
func GetGoVersion(a Animal) string {
    name := a.GetName()
    return name
}
```

首先用gomock提供的mockgen工具生成要mock的接口的实现：

> mockgen has two modes of operation: source and reflect. 
> * Source mode generates mock interfaces from a source file. 
> * Reflect mode generates mock interfaces by building a program that uses reflection to understand interfaces.

- source： 指定接口文件 （不使用-source的时，mockgen使用反射来找到对应的接口）
- destination: 生成的mock文件名
- package:生成mock文件的包名
- imports: 依赖的需要import的包
- aux_files:接口文件不止一个文件时附加文件
- build_flags: 传递给build工具的参数

```
#根据sweeat.me/test/gomock下的Animal类型，生成animal_mock.go（位于animal包下）
#mockgen -destination animal_mock.go -package packagename interface_importpath interface
mockgen -destination animal_mock.go -package animal sweeat.me/test/gomock Animal
```

使用mock：

```
package animal

import (
    "testing"

    "github.com/golang/mock/gomock"
)

func TestGetGoVersion(t *testing.T) {
    mockCtl := gomock.NewController(t)
    mockAnimal := NewMockAnimal(mockCtl)
    mockAnimal.EXPECT().GetName().Return("dog")
    v := GetGoVersion(mockAnimal)
    if v != "dog" {
        t.Error("Get wrong name :", v)
    }
}
```

如果有多个文件，并且分散在不同的位置，那么要生成mock文件的时候，需要对每个文件执行多次mockgen命令（假设包名不相同）。这样在真正操作起来的时候非常繁琐，mockgen还提供了一种通过注释反射生成mock文件的方式，此时需要借助go的"go generate "工具。

在接口文件的注释里面增加如下：

```
//go:generate mockgen -destination mock_spider.go -package spider github.com/cz-it/blog/blog/Go/testing/gomock/example/spider Spider
```

这样，只要在spider目录下执行

```
go generate
```

## 2. 定义包内全局变量进行函数mock ##

```
var osOpen = os.Open
func read(path string) error {
    f, err := osOpen("notes.txt")
    if err != nil {
        return err
    }
    return nil
}
```

测试的时候定义自己的函数去替换系统函数。

```
    oldOsOpen := osOpen
    defer func() { osOpen = oldOsOpen }()

    myOpen := func(path string)(*os.File, error) {
        return nil, nil
    }
    osOpen = myOpen
```

这种做法比较容易出错，需要用到全局变量，但是确实可以把一些不能测到的函数变得可测试，当然也可以使用接口的方法，让 read 函数接收一个 io.Reader interface, 这种方法就好得多。

## 3. 将函数作为参数传递进行mock ##

还有一种比较改进的做法是把函数作为参数放到参数里面。通过把函数作为参数，也可以很容易的mock掉函数调用函数的情况，但是这种做法适用于函数内调用函数的数量比较少，否则需要传递大量的函数参数作为输入，这样代码写出来也很丑陋。

```
type OpenFunc func(string) (*File, error)
func read(fn OpenFunc, path string) error {
    f, err := fn(path)
    if err != nil {
        return err
    }
    return nil
}
```

