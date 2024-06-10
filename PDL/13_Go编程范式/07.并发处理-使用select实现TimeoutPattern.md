# 并发处理-插叙:TimeoutPattern #

select可以用来与 [time.After](https://golang.org/pkg/time/#After)（a function that returns a channel and sends on that channel after the specified duration）配合使用控制通信超时，终止退出通信。

```
func main() {
	result:=make(chan string)
	go func() {
		time.Sleep(1*time.Second)
		result<-"done"
	}()
	select {
	case <-time.After(2*time.Second):
		fmt.Println("timeout")
	case c:=<-result:
		fmt.Println(c)
	}
}
```