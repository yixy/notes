---
categories:
- 云计算
date: "2019-09-30T14:53:49+08:00"
lastmod: "2019-10-02T17:04:22+08:00"
tags:
- 云计算
- Golang
title: Go语言测试(3)-go test缓存机制
---

## 1. 单元测试中print时间输出不变的问题 ##

写单元测试的时候发现如下测试案例输出结果不变，但是正常在main函数中编译执行是没有问题的。查了下文档，原因在于go test会缓存测试结果。

```
func TestPrint(t *testing.T){
    fmt.Println(time.Now())
}
```

## 2. go test 缓存 ##

go 在 1.10 版本中引入了 go tool 的缓存，此功能会缓存 go test执行的结果。 每当执行 go test 时，如果功能代码和测试代码没有变动，则在下一次执行时，会直接读取缓存中的测试结果。 

注意， go test -v . 和 go test .是分开缓存的。

可以通过增加`-count=1`来避免缓存结果。

```
go test -count=1 -v .
```