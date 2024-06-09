
## select的优先级 ##

https://studygolang.com/articles/6364
https://www.liwenzhou.com/posts/Go/priority_in_go_select/

先执行job1，再执行job2


```
func worker(ch1, ch2 <-chan int, stopCh chan struct{}) {

    for {
        select {
        case <-stopCh:
            return
        case job1 := <-ch1:
            fmt.Println(job1)
        default:
            select {
            case job2 := <-ch2:
                fmt.Println(job2)
            default:
            }
        }
    }
}
```
上面的代码通过嵌套两个select实现了”优先级”，看起来是满足题目要求的。但是这代码有点问题，如果ch1和ch2都没有达到就绪状态的话，整个程序不会阻塞而是进入了死循环。
```
func worker2(ch1, ch2 <-chan int, stopCh chan struct{}) {
    for {
        select {
        case <-stopCh:
            return
        case job1 := <-ch1:
            fmt.Println(job1)
        case job2 := <-ch2:
        priority:
            for {
                select {
                case job1 := <-ch1:
                    fmt.Println(job1)
                default:
                    break priority
                }
            }
            fmt.Println(job2)
        }
    }
}
```