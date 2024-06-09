# 熔断限流-Hystrix-go熔断 #

hystrix是一个容错库，旨在隔离指向远程系统，服务和第三方库的请求，杜绝级联故障，并在复杂的分布式系统中实现弹性，毕竟在分布式系统中，故障是不可避免的。

此项目脱胎于由Netflix开源的同名java项目。https://github.com/Netflix/Hystrix


```
package main
import (
	"fmt"
	"github.com/afex/hystrix-go/hystrix"
	"net/http"
	"time"
)
func main() {
	hystrix.Go("get_baidu", func() error {
		// talk to other services
		_, err := http.Get("https://www.baidu.com/")
		if err != nil {
			fmt.Println("get error")
			return err
		}
		return nil
	}, func(err error) error {
		fmt.Println("get an error, handle it")
		return nil
	})
 
	time.Sleep(2 * time.Second)  // 调用Go方法就是起了一个goroutine，这里要sleep一下，不然看不到效果
}
```

调用一个借口并且等待返回是一个常见的场景（对应于goroutine），Hystrix提供了一个Do函数，返回一个error

其实方法Do和Go方法内部都是调用了hystrix.GoC方法，只是Do方法处理了异步的过程

在调用Do Go等方法之前我们可以先自定义一些配置

```
	hystrix.ConfigureCommand("mycommand", hystrix.CommandConfig{
		Timeout:                int(time.Second * 3),
		MaxConcurrentRequests:  100,
		SleepWindow:            int(time.Second * 5),
		RequestVolumeThreshold: 30,
		ErrorPercentThreshold: 50,
	})

	err := hystrix.DoC(context.Background(), "mycommand", func(ctx context.Context) error {
		// ...
		return nil
	}, func(i context.Context, e error) error {
		// ...
		return e
	})
```

我大要说了一下CommandConfig第个字段的意义：

* Timeout: 执行command的超时时间。默认时间是1000毫秒
* MaxConcurrentRequests：command的最大并发量 默认值是10
* SleepWindow：当熔断器被打开后，SleepWindow的时间就是控制过多久后去尝试服务是否可用了。默认值是5000毫秒
* RequestVolumeThreshold： 一个统计窗口10秒内请求数量。达到这个请求数量后才去判断是否要开启熔断。默认值是20
* ErrorPercentThreshold：错误百分比，请求数量大于等于RequestVolumeThreshold并且错误率到达这个百分比后就会启动熔断 默认值是50

当然如果不配置他们，会使用默认值