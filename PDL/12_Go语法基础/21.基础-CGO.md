# 基础——CGO #

> Go程序可能会遇到要访问C语言的某些硬件驱动函数的场景，或者是从一个C++语言实现的嵌入式数据库查询记录的场景，或者是使用Fortran语言实现的一些线性代数库的场景。C语言作为一个通用语言，很多库会选择提供一个C兼容的API，然后用其他不同的编程语言实现。Go语言需要也应该拥抱这些巨大的代码遗产。——《The Go Programing Language》

如果我们对性能也没有特殊要求的话，我们可以用os/exec包的方法将C编写的应用程序作为一个子进程运行（用os/exec包调用子进程的方法会导致程序运行时依赖那个应用程序）。但当需要使用复杂而且性能更高的底层C接口时，我们就需要使用到cgo。

## 1. Go调用C函数 ##

cgo是Go语言自带的用于支援C语言函数调用的工具。这类工具一般被称为 foreign-function interfaces （简称FFI）。

一个简单的通过cgo调用C语言程序的例子如下。

```
$ cat prints.h
void prints(char* str);

$ cat prints.c
#include <stdio.h>
#include "prints.h"
void prints(char* str)
{
  printf("%s\n", str);
}

$ cat prints.go
package prints
//#include "prints.h"
import "C"
func Prints(s string) {
	p := C.CString(s);
	C.prints(p);
}

```

其中import "C"的语句是比较特别的。其实并没有一个叫C的包，但是这行语句会让Go编译程序在编译之前先运行cgo工具。在预处理过程中，cgo工具会生成一个临时包用于包含所有在Go语言中访问的C语言的函数或类型，例如C.CString。import "C"语句前仅挨着的注释是对应cgo的特殊语法，对应必要的构建参数选项和C语言代码。cgo工具通过以某种特殊的方式调用本地的C编译器来发现在Go源文件导入声明前的注释中包含的C头文件中的内容。

需要注意的内容：

**1. /\* \*/注释的代码下一行一定是import "C"，中间不能有空行**

**2.import "C"必须单独一行，不能和其它库一起导入**

另外，Go中调用C函数，C函数可以有第二个返回值，其值为errno，对应error接口类型。

## 2. C调用Go导出的函数 ##

注意，Go导出的C函数没有命名空间约束，需保证全局唯一性。

导出函数会在_cgo_export.h中声明。

例子1。

```
package main
// extern void SayHello(char* s);
import "C"
import "fmt"
func main() {
    C.SayHello(C.CString("Hello, World\n"))
}
//export SayHello
func SayHello(s *C.char) {
    fmt.Print(C.GoString(s))
}
```

例子2。Go1.10增加了预定义的_GoString_类型，与GoString等价。

```
package main
// extern void SayHello(_GoString_ s);
import "C"
import "fmt"
func main() {
    C.SayHello("Hello, World\n")
}
//export SayHello
func SayHello(s string) {
    fmt.Print(s)
}
```

## 3. Go与C的类型转换 ##

unsafe包提供以下方法。

* Pointer：面向编译器无法保证安全的指针类型转换。
* Sizeof：值所对应变量在内存中的大小。
* Alignof：值所对应变量在内存中地址几个字节对齐。
* Offsetof：结构体中成员变量的偏移量。

一些类型转换的例子如下。

```
// int32 => *C.char
var x = int32(9527)
var p *C.char = (*C.char)(unsafe.Pointer(uintptr(x)))
// *C.char => int32
var y *C.char
var q int32 = int32(uintptr(unsafe.Pointer(y)))

var p *X
var q *Y
q = (*Y)(unsafe.Pointer(p)) // *X => *Y
p = (*X)(unsafe.Pointer(q)) // *Y => *X

var p []X
var q []Y // q = p
pHdr := (*reflect.SliceHeader)(unsafe.Pointer(&p))
qHdr := (*reflect.SliceHeader)(unsafe.Pointer(&q))
pHdr.Data = qHdr.Data
pHdr.Len = qHdr.Len * unsafe.Sizeof(q[0]) / unsafe.Sizeof(p[0]
pHdr.Cap = qHdr.Cap * unsafe.Sizeof(q[0]) / unsafe.Sizeof(p[0]

// []float64 []int
var a = []float64{4, 2, 5, 7, 2, 1, 88, 1}
var b []int = ((*[1 << 20]int)(unsafe.Pointer(&a[0])))[:le
// int float64
sort.Ints(b)
```

## 4. Go使用静态库 ##

头文件。

```
//number/number.h
int number_add_mod(int a, int b, int mod);
```

对应函数的实现。

```
#include "number.h"

int number_add_mod(int a, int b, int mod) {
    return (a+b)%mod;
}
```

因为CGO使用的是GCC命令来编译和链接C和Go桥接的代码。因此静态库也必须是GCC兼容的格式。通过以下命令可以生成一个libnumber.a的静态库：

```
$ cd ./number
$ gcc -c -o number.o number.c
$ ar rcs libnumber.a number.o
```

其中有两个#cgo命令，分别是编译和链接参数。CFLAGS通过-I./number将number库对应头文件所在的目录加入头文件检索路径。LDFLAGS通过-L${SRCDIR}/number将编译后number静态库所在目录加为链接库检索路径，-lnumber表示链接libnumber.a静态库。需要注意的是，在链接部分的检索路径不能使用相对路径（这是由于C/C++代码的链接程序所限制），我们必须通过cgo特有的${SRCDIR}变量将源文件对应的当前目录路径展开为绝对路径（因此在windows平台中绝对路径不能有空白符号）。

```
//#cgo CFLAGS: -I./number
//#cgo LDFLAGS: -L${SRCDIR}/number -lnumber
//
//#include "number.h"
import "C"
import "fmt"
func main() {
    fmt.Println(C.number_add_mod(10, 5, 12))
}
```

## 5. Go使用动态库 ##

继续用上面的例子，我们可以用以下命令创建number库的的动态库：

```
$ cd number
$ gcc -shared -o libnumber.so number.c
```

因为动态库和静态库的基础名称都是libnumber，只是后缀名不同而已。因此Go语言部分的代码和静态库版本完全一样，编译时GCC会自动找到libnumber.a或libnumber.so进行链接。

```
package main

//#cgo CFLAGS: -I./number
//#cgo LDFLAGS: -L${SRCDIR}/number -lnumber
//
//#include "number.h"
import "C"
import "fmt"

func main() {
    fmt.Println(C.number_add_mod(10, 5, 12))
}
```

需要注意的是，在运行时需要将动态库放到系统能够找到的位置。对于windows来说，可以将动态库和可执行程序放到同一个目录，或者将动态库所在的目录绝对路径添加到PATH环境变量中。对于macOS来说，需要设置DYLD_LIBRARY_PATH环境变量。而对于Linux系统来说，需要设置LD_LIBRARY_PATH环境变量。

## 6. Go导出静态库和动态库 ##

```
package main
import "C"
func main() {}
//export number_add_mod
func number_add_mod(a, b, mod C.int) C.int {
    return (a + b) % mod
}
```

$ go build -buildmode=c-archive -o number.a

$ go build -buildmode=c-shared -o number.so


## 6. 参考 ##

Go语言高级编程(Advanced Go Programming)，柴树杉
