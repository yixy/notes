# Troubleshooting——WaitGroup使用引出的两个问题 #

## 1. WaitGroup的同步问题 ##

以下代码没有任何输出。

```go
package main
import (
    "log"

    "sync"
)
func main() {
    wg := sync.WaitGroup{}

    for i := 0; i < 5; i++ {
        go func(wg sync.WaitGroup, i int) {
            wg.Add(1)
            log.Printf("i:%d", i)
            wg.Done()
        }(wg, i)
    }

    wg.Wait()

    log.Println("exit")
}
```

因为 WaitGroup 同步的是 goroutine, 而上面的代码却在 goroutine 中进行 Add(1) 操作。因此，可能在这些 goroutine 还没来得及 Add(1) 已经执行 Wait 操作了。

## 2. 参数的值传递问题 ##

下面代码存在的问题：wg 给拷贝传递到了 goroutine 中，导致只有 Add 操作，其实 Done操作是在 wg 的副本执行的。因此 Wait 就死锁了。

```go
package main
import (
    "log"

    "sync"
)
func main() {
    wg := sync.WaitGroup{}

    for i := 0; i < 5; i++ {
        wg.Add(1)
        go func(wg sync.WaitGroup, i int) {
            log.Printf("i:%d", i)
            wg.Done()
        }(wg, i)
    }

    wg.Wait()

    log.Println("exit")
}
```

## 3. 最终的例子 ##

```go
package main

import (
    "log"

    "sync"
)

func main() {
    wg := &sync.WaitGroup{}

    for i := 0; i < 5; i++ {
        wg.Add(1)
        go func(wg *sync.WaitGroup, i int) {
            log.Printf("i:%d", i)
            wg.Done()
        }(wg, i)
    }

    wg.Wait()

    log.Println("exit")
}
```