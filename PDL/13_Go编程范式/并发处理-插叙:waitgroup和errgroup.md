# 并发处理-插叙:waitgroup和errgroup #

## 1 sync.WaitGroup ##

WaitGroup的用途：它能够一直等到所有的goroutine执行完成，并且阻塞主线程的执行，直到所有的goroutine执行完成。

sync.WaitGroup只有3个方法，Add()，Done()，Wait()。

其中Done()是Add(-1)的别名。简单的来说，使用Add()添加计数，Done()减掉一个计数，计数不为0, 阻塞Wait()的运行。

注意，因为 WaitGroup 同步的是 goroutine, 所以如果在 goroutine 中进行 Add(1) 操作，会导致可能在这些 goroutine 还没来得及 Add(1) 已经执行 Wait 操作了。

```
package main
import (
    "fmt"
    "sync"
)
type syncMap struct {
    items map[string]int
    sync.RWMutex
}
func main() {
    c := &syncMap{items: make(map[string]int)}
    var w sync.WaitGroup
    for i := 0; i < 100; i++ {
        w.Add(1)
        go func() {
            //w.Add(1) 在携程中Add这是一个错误的写法，因为可能协程还没开始执行，wait()方法就执行退出了。
            for j := 0; j < 1000000; j++ {
                //读写锁
                c.Lock()
                c.items[fmt.Sprintf("%d", j)] = j
                c.Unlock()
            }
            w.Done()
        }()
    }
    w.Wait()
}
```

## 2  sync.Errgroup ##

***golang.org/x/sync/errgroup：https://pkg.go.dev/golang.org/x/sync/errgroup***

* Package errgroup provides synchronization, error propagation, and Context cancelation for groups of goroutines working on subtasks of a common task.

eg.Wait等待所有任务处理完成后再返回，将第一个异常返回给用户，否则返回空。


```
package main

import (
    "fmt"
    "log"
    "time"

    "golang.org/x/sync/errgroup"
)

func main() {
    var eg errgroup.Group
    for i := 0; i < 100; i++ {
        i := i
        eg.Go(func() error {
            time.Sleep(500 * time.Millisecond)
            if i > 90 {
                fmt.Println("Error:", i)
                return fmt.Errorf("Error occurred: %d", i)
            }
            fmt.Println("End:", i)
            return nil
        })
    }
    if err := eg.Wait(); err != nil {
        log.Fatal(err)
    }
}
```

WithContext 就是使用 WithCancel 创建一个可以取消的 context 将 cancel 赋值给 Group 保存起来，然后再将 context 返回回去。各任务可以通过ctx.Done()监听取消操作，此时，任意任务失败，errgroup将调用cancel方法取消所有其他任务，快速返回失败信息。


```
package main

import (
    "context"
    "fmt"
    "log"
    "time"

    "golang.org/x/sync/errgroup"
)

func main() {
    eg, ctx := errgroup.WithContext(context.Background())

    for i := 0; i < 100; i++ {
        i := i
        eg.Go(func() error {
            time.Sleep(500 * time.Millisecond)

            select {
            case <-ctx.Done():
                fmt.Println("Canceled:", i)
                return nil
            default:
                if i > 90 {
                    fmt.Println("Error:", i)
                    return fmt.Errorf("Error: %d", i)
                }
                fmt.Println("End:", i)
                return nil
            }
        })
    }
    if err := eg.Wait(); err != nil {
        log.Fatal(err)
    }
}
```