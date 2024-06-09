# 错误处理-HandlingError #

## 1 error处理放入缩进块：Indented flow is for errors ##

采用如下的方式，无错误的正常流程代码将成为一条直线，而不是成为缩进的代码。

```
f,err:=os.Open(path)
if err!=nil{
        //handle error
}
//do stuff
```

## 2 优雅消除errors：Eliminate error handling by eliminating errors ##

**Don’t just check errors, handle them gracefully**

eg1.

```
func AuthenticateRequest(r *Request) error {
        err := authenticate(r.User)
        if err != nil {
                return err
        }
        return nil
}

func AuthenticateRequest(r *Request) error {
        return authenticate(r.User)
}

```

eg2.

```
func CountLines(r io.Reader) (int, error) {
        var (
                br    = bufio.NewReader(r)
                lines int
                err   error
        )

        for {
                _, err = br.ReadString('\n')
                lines++
                if err != nil {
                        break
                }
        }

        if err != io.EOF {
                return 0, err
        }
        return lines, nil
 }

func CountLines(r io.Reader) (int, error) {
        sc := bufio.NewScanner(r)
        lines := 0

        for sc.Scan() {
                lines++
        }

        return lines, sc.Err()
}
```

**repetitive  error handling**

When dealing with opening, writing and closing files, the error handling is present but not overwhelming as, the operations can be encapsulated in helpers like ioutil.ReadFile and ioutil.WriteFile. However, when dealing with low level network protocols it often becomes necessary to build the response directly using I/O primitives, thus the error handling can become repetitive. Consider this fragment of a HTTP server which is constructing a HTTP/1.1 response.(在处理打开、写入和关闭文件时，错误处理是存在的，但并不复杂，因为这些操作可以封装在 ioutil.ReadFile 和 ioutil.WriteFile 等帮助程序中。但是，在处理低级网络协议时，通常需要使用 I/O 原语直接构建响应，因此错误处理可能会变得重复。考虑构建 HTTP/1.1 响应的 HTTP 服务器的这个片段。)

```
type Header struct {
        Key, Value string
}

type Status struct {
        Code   int
        Reason string
}

func WriteResponse(w io.Writer, st Status, headers []Header, body io.Reader) error {
        _, err := fmt.Fprintf(w, "HTTP/1.1 %d %s\r\n", st.Code, st.Reason)
        if err != nil {
                return err
        }
        
        for _, h := range headers {
                _, err := fmt.Fprintf(w, "%s: %s\r\n", h.Key, h.Value)
                if err != nil {
                        return err
                }
        }

        if _, err := fmt.Fprint(w, "\r\n"); err != nil {
                return err
        } 

        _, err = io.Copy(w, body) 
        return err
}
```

we can make it easier on ourselves by introducing a small wrapper type.

errWriter fulfils the io.Writer contract so it can be used to wrap an existing io.Writer. errWriter passes writes through to its underlying writer until an error is detected. From that point on, it discards any writes and returns the previous error.


```
type errWriter struct {
        io.Writer
        err error
}

func (e *errWriter) Write(buf []byte) (int, error) {
        if e.err != nil {
                return 0, e.err
        }

        var n int
        n, e.err = e.Writer.Write(buf)
        return n, nil
}

func WriteResponse(w io.Writer, st Status, headers []Header, body io.Reader) error {
        ew := &errWriter{Writer: w} 
        fmt.Fprintf(ew, "HTTP/1.1 %d %s\r\n", st.Code, st.Reason)

        for _, h := range headers {
                fmt.Fprintf(ew, "%s: %s\r\n", h.Key, h.Value)
        }

        fmt.Fprint(ew, "\r\n")
        io.Copy(ew, body)

        return ew.err
}
```

注意，以上使用场景也就只能在对于同一个业务对象的不断操作下可以简化错误处理，对于多个业务对象的话，还是得需要各种 if err != nil的方式。

## 3 Wrap erros ##

还记得之前优化之前的 auth 代码吧，如果 authenticate 返回错误，则 AuthenticateRequest 会将错 误返回给调用方，调用者可能也会这样做，依此类推。在程序的顶部，程序的主体将把错误打印到 屏幕或日志文件中，打印出来的只是：no such file or directory（没有这样的文件或目录）。


```
func AuthenticateRequest(r *Request) error {
        return authenticate(r.User)
}
```

**以上error handle存在都问题：如上代码没有生成错误的上下文信息，比如 file:line 信息（调用堆栈）。这段代码的作者将被迫进行长时间的代码分割，以发现是哪个代码路径触发了文件未找到错误。**

下面我们讨论下常见的包含上下文信息的error handle方式：

**1. return annatated error（不推荐）**

将错误值转换为字符串，将其与另一个字符串合并，然后将其转换回error并返回。

这种模式与 sentinel errors 或 type assertions 的使用不兼容，因为  fmt.Errorf 破坏了原始错误，可能导致调用方的等值判定失败。另外，这种合并拼接的方式信息格式比较乱，同时调用堆栈也比较难放入annatated中。

```
func AuthenticateRequest(r *Request) error {
        err := authenticate(r.User)
        if err != nil {
                return fmt.Errorf("no auth: %v",err)
        }
        return nil
}
```

**2. log annatated error（不推荐）**

在错误处理中，带了两个任务: 记录日志并且再次返回错误。大部分日志构件可以包含堆栈上下文信息。

这种方式虽然上下文每个地方都打了日志，但实现上并不优雅，并且实际上日志看起来也不够清晰。另外，某些情况下，忘记处理（返回）错误，可能导致程序逻辑出现问题，存在相关的编码风险。


```
func AuthenticateRequest(r *Request) error {
        err := authenticate(r.User)
        if err != nil {
                log.Println("no auth:",err)
                return err
        }
        return nil
}
```

**期望像Java一样，底层抛了一个exception，各个调用方都往上层抛，在最上层捕获exception，并且打印含堆栈上下文的日志且只打印一次。因为除最上层外，其他层打印的堆栈日志实际上都是重复的。**

>  you should only handle errors once. Handling an error means inspecting the error value, and making a single decision. 

###### 使用开源库`github.com/pkg/errors`实现wrap error。###### 

application代码中在handle产生根因错误的地方（高可重用性的代码库 或者 errors.New/errors.Errorf）去wrap，在最上层打印堆栈日志：

```
var GlobalErr error
var GlobalErrI interface{}
func ReadFile(path string) ([]byte, error) {
	f, err := os.Open(path)
	GlobalErr=err
	GlobalErrI=err
	if err != nil {
		//根因错误，进行wrap，包含了堆栈信息
		return nil, errors.Wrap(err, "open failed")
	}
	defer f.Close()

	buf, err := ioutil.ReadAll(f)
	if err != nil {
		//根因错误，进行wrap，包含了堆栈信息
		return nil, errors.Wrap(err, "read failed")
	}
	return buf, nil
}

func ReadConfig() ([]byte, error) {
	home := os.Getenv("HOME")
	config, err := ReadFile(filepath.Join(home, ".settings.xml"))
	//非根因错误，可以直接返回error，WithMessage用于携带附加信息，不包含堆栈信息
	return config, errors.WithMessage(err, "could not read config")
}

func test()  {
	_, err := ReadConfig()
	if err != nil {
		//非根因错误，可以直接返回error，WithMessage用于携带附加信息，不包含堆栈信息
		errs:=errors.WithMessage(err,"top message")
		//%+v打印堆栈信息
		fmt.Printf("%+v",errs)
		fmt.Printf("\nerrors.Is: %t",errors.Is(errs,GlobalErr))
		fmt.Printf("\nerrors.As: %t",errors.As(errs,&GlobalErr))
		os.Exit(1)
	}
}

func main() {
	test()
}

```

打印的堆栈信息如下：（根因错误、wrap的annotate、堆栈、其他层annotate）

```
//fmt.Printf("%+v",errs)
//根因错误
open /Users/youzhilane/.settings.xml: no such file or directory
//wrap的annotate
open failed
//堆栈
main.ReadFile
	/Users/youzhilane/myworkspace/test/geek_crawler/main.go:34
main.ReadConfig
	/Users/youzhilane/myworkspace/test/geek_crawler/main.go:47
main.test
	/Users/youzhilane/myworkspace/test/geek_crawler/main.go:52
main.main
	/Users/youzhilane/myworkspace/test/geek_crawler/main.go:63
runtime.main
	/usr/local/go/src/runtime/proc.go:225
runtime.goexit
	/usr/local/go/src/runtime/asm_amd64.s:1371
//其他层annotate
could not read config
top message

//fmt.Printf("\nerrors.Is: %t",errors.Is(errs,GlobalErr))
errors.Is: true
//fmt.Printf("\nerrors.As: %t",errors.As(errs,&GlobalErr))
errors.As: true

Process finished with exit code 1
``` 

* github.com/pkg/errors.Wrap：handle根因错误，该方法签名返回一个新error，其中包含原始底层信息和堆栈annotate上下文信息
* github.com/pkg/errors.Cause(err)：从err中获取原始根因错误
* github.com/pkg/errors.WithMessage：handle非根因错误，该方法签名返回一个新error，其中包含原始底层信息和annotate上下文信息
* github.com/pkg/errors.Is(err,target)：判断被包装的 error 是否是包含指定错误。递归调用 Unwrap 并判断每一层的 err 是否相等，如果有任何一层 err 和传入的目标错误相等，则返回 true。reports whether any error in err's chain matches target.
* github.com/pkg/errors.As(err,errAuth)：这个和上面的 errors.Is 大体上是一样的，区别在于 Is 是严格判断相等，即两个 error 是否相等。而 As 则是判断类型是否相同，并提取第一个符合目标类型的错误，用来统一处理某一类错误。As finds the first error in err's chain that matches target, and if so, sets target to that error value and returns true.

> 个人感觉，如果采用Opaque errors，基本上很少需要使用Is和As方法了？

**高可重用性的代码库只能返回根因错误**：application代码才使用pkg/errors包进行wrap error，具有高可重用性的代码库（比如标准库、第三方库或者本地基础库等）不能使用wrap error。

**application代码handle根因错误(高可重用性的代码库或者 errors.New/errors.Errorf)需要wrap**：在application代码（最外层业务程序工程）中，只有调用具有高可重用性的代码库（比如标准库、第三方库、本地基础库或者 errors.New/errors.Errorf）的时候，才能使用errors.Wrap或errors.Wrapf进行wrap。

> 注意，errors.New/errors.Errorf方法定义根因错误时，比较好的方式是在错误信息中加上packagename

**application代码handle非根因错误时error直接返回**：在application代码（最外层业务程序工程）中，调用工程代码中的其他函数时，非根因错误error直接透传返回。

**application代码顶部或请求入口goroutine处记录堆栈日志**：在application代码（最外层业务程序工程）的顶部或goroutine顶部（请求入口），使用%+v打印堆栈详情记录。

###### Go1.13的错误处理 ###### 

Go 1.13在errors和fmt标准库包中引入了新功能以简化处理包含其他错误的错误。其中最重要的不是改变，而是一个约定：包含另一个错误的错误可以实现Unwrap方法来返回所包含的底层错误。如果e1.Unwrap()返回了e2，那么我们说e1包装了e2，您可以Unwrap e1来得到e2。

```
//go1.13中支持%w谓词添加annotate生成新error，类似于github.com/pkg/errors.WithMessage
deErr:=fmt.Errorf("decompress %v: %w", name, err)
//deErr.Unwrap可以返回底层的根因错误
```

实际上fmt.Errorf通过%w谓词生成的新error中是不包含堆栈信息的，所以暂时还是建议使用github.com/pkg/errors