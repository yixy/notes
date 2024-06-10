# 使用编译参数ldflags将版本信息写入二进制文件 #

我们经常会在一些程序的输出中看到程序版本、编译时间等信息。

我们可以提供一个配置文件version.conf，程序运行时从version.conf取得这些信息进行显示。但是在部署程序时，除了二进制文件还需要额外的配置文件，不是很方便。

或者将这些信息写入代码中，这样不需要额外的version.conf，但要在每次编译时修改代码文件，也很麻烦。

有一种更好的办法是在编译时使用参数-ldflags -X importpath.name=value，官方解释如下：

```
https://golang.org/cmd/link/

-X importpath.name=value
	Set the value of the string variable in importpath named name to value.
	Note that before Go 1.5 this option took two separate arguments.
	Now it takes one argument split on the first = sign.
```

效果展示如下：

```
$ ls
main.go version
$ ls version
version.go
$ go build -ldflags "-X sweeat.me/test/version.version=1.0 -X sweeat.me/test/version.date=2018-04-17" main.go
$ ./main -version
Version: 1.0
Compile date: 2018-04-17
```

main.go代码如下：

```
package main
import (
    "fmt"
    _ "sweeat.me/test/version"
)
func main() {
    fmt.Println("ok")
}
```

version.go代码如下：

```
package version
import (
     "flag"
     "fmt"
     "io"
     "os"
)
var showVersion = flag.Bool("version", false, "Print version of this binary")
var (
     version string
     date string
)
func init() {
     if !flag.Parsed() {
           flag.Parse()
     }
     if showVersion != nil && *showVersion {
           printVersion(os.Stdout, version, date)
           os.Exit(0)
    }
}
func printVersion(w io.Writer, version string, date string) {
     fmt.Fprintf(w, "Version: %s\n", version)
     fmt.Fprintf(w, "Compile date: %s\n", date)
}
```
