# IO标准库 #

## 1. io 与 io/ioutil ##

> package io：io包提供了对I/O原语的基本接口。本包的基本任务是包装这些原语已有的实现（如os包里的原语），使之成为共享的公共接口，这些公共接口抽象出了泛用的函数并附加了一些相关的原语的操作。因为这些接口和原语是对底层实现完全不同的低水平操作的包装，除非得到其它方面的通知，客户端不应假设它们是并发执行安全的。
> package io/ioutil：Package ioutil implements some I/O utility functions.

io.Reader：Read方法读取len(p)字节数据写入p。它返回写入的字节数和遇到的任何错误。调用者应该总是先处理读取的n > 0字节再处理错误值。这么做可以正确的处理发生在读取部分数据后的I/O错误，也能正确处理EOF事件。

```
type Reader interface {
    Read(p []byte) (n int, err error)
}
```

io.Writer：Write方法将len(p) 字节数据从p写入底层的数据流。它会返回写入的字节数(0 <= n <= len(p))和遇到的任何导致写入提取结束的错误。如果它返回的 n < len(p)，Write必须返回非nil的错误。Write不能修改切片p中的数据，即使临时修改也不行。

```
type Writer interface {
    Write(p []byte) (n int, err error)
}
```

io.Closer：Closer接口用于包装基本的关闭方法。在第一次调用之后再次被调用时，Close方法的的行为是未定义的。某些实现可能会说明他们自己的行为。

```
type Closer interface {
    Close() error
}
```

ioutil.ReadAll：ReadAll从r读取数据直到EOF或遇到error，返回读取的数据和遇到的错误。成功的调用返回的err为nil而非EOF。因为本函数定义为读取r直到EOF，它不会将读取返回的EOF视为应报告的错误。

```
func ReadAll(r io.Reader) ([]byte, error)
```

## 2. bytes包 ##

bytes.Reader：Reader类型通过从一个[]byte读取数据，实现了io.Reader、io.Seeker、io.ReaderAt、io.WriterTo、io.ByteScanner、io.RuneScanner接口。

```
type Reader
type Reader struct {
    // 内含隐藏或非导出字段
}
```

bytes.Buffer：Buffer是一个实现了读写方法的可变大小的字节缓冲。本类型的零值是一个空的可用于读写的缓冲。

```
type Buffer struct {
    // 内含隐藏或非导出字段
}
```
