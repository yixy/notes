channel得在主协程才能实现并发控制，因为它本质上是一个队列

简单的并发控制
利用 channel 的缓冲设定，我们就可以来实现并发的限制。我们只要在执行并发的同时，往一个带有缓冲的 channel 里写入点东西（随便写啥，内容不重要）。让并发的 goroutine在执行完成后把这个 channel 里的东西给读走。这样整个并发的数量就讲控制在这个 channel的缓冲区大小上。

比如我们可以用一个 bool 类型的带缓冲 channel 作为并发限制的计数器。

   chLimit := make(chan bool, 1)
然后在并发执行的地方，每创建一个新的 goroutine，都往 chLimit 里塞个东西。

    for i, sleeptime := range input {
    chs[i] = make(chan string, 1)
    chLimit <- true
    go limitFunc(chLimit, chs[i], i, sleeptime, timeout)
}
这里通过 go 关键字并发执行的是新构造的函数。他在执行完后，会把 chLimit的缓冲区里给消费掉一个。

     limitFunc := func(chLimit chan bool, ch chan string, task_id, sleeptime, timeout int) {
    Run(task_id, sleeptime, timeout, ch)
    <-chLimit
}
这样一来，当创建的 goroutine 数量到达 chLimit 的缓冲区上限后。主 goroutine 就挂起阻塞了，直到这些 goroutine 执行完毕，消费掉了 chLimit 缓冲区中的数据，程序才会继续创建新的 goroutine 。我们并发数量限制的目的也就达到了。

例子

     package main
 
import (
    "fmt"
    "time"
)
 
func Run(task_id, sleeptime, timeout int, ch chan string) {
    ch_run := make(chan string)
    go run(task_id, sleeptime, ch_run)
    select {
    case re := <-ch_run:
        ch <- re
    case <-time.After(time.Duration(timeout) * time.Second):
        re := fmt.Sprintf("task id %d , timeout", task_id)
        ch <- re
    }
}
 
func run(task_id, sleeptime int, ch chan string) {
 
    time.Sleep(time.Duration(sleeptime) * time.Second)
    ch <- fmt.Sprintf("task id %d , sleep %d second", task_id, sleeptime)
    return
}
 
func main() {
    input := []int{3, 2, 1}
    timeout := 2
    chLimit := make(chan bool, 1)
    chs := make([]chan string, len(input))
    limitFunc := func(chLimit chan bool, ch chan string, task_id, sleeptime, timeout int) {
        Run(task_id, sleeptime, timeout, ch)
        <-chLimit
    }
    startTime := time.Now()
    fmt.Println("Multirun start")
    for i, sleeptime := range input {
        chs[i] = make(chan string, 1)
        chLimit <- true
        go limitFunc(chLimit, chs[i], i, sleeptime, timeout)
    }
 
    for _, ch := range chs {
        fmt.Println(<-ch)
    }
    endTime := time.Now()
    fmt.Printf("Multissh finished. Process time %s. Number of task is %d", endTime.Sub(startTime), len(input))
}
运行结果：

     Multirun start
     task id 0 , timeout
     task id 1 , timeout
     task id 2 , sleep 1 second
     Multissh finished. Process time 5s. Number of task is 3
如果修改并发限制为2：

     chLimit := make(chan bool, 2)
运行结果：

    Multirun start
    task id 0 , timeout
    task id 1 , timeout
    task id 2 , sleep 1 second
    Multissh finished. Process time 3s. Number of task is 3