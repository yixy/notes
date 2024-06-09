# 并发处理-WorkerPools #

Go的runtime已经将多个协程映射到内核线程上了。所以需要开启多个无依赖的并行任务，最朴素的想法是直接使用多个go关键字开启多个goroutine去处理相关任务。这种方式存在的问题：

* 任务失败时不知道错误原因，比如使用waitgroup的场景
* 不知道这些goroutine什么时候结束，只能依靠channel等待多个任务结束返回，自己实现处理比较复杂
* 任意任务失败的情况下，不易于快速取消。

## 1 Worker lifecycle & Limit work in flight ##

非主干逻辑，旁路去执行异步任务，最朴素的想法是直接使用go关键字开启野生goroutine去执行相关任务。但野生goroutine存在的问题：

* Limit work in flight ：每次开启野生goroutine存在一定的性能开销，所以需要限制协程数量
* Worker lifecycle：野生goroutine的生命周期管理比较困难（例如，接收到SIGQUIT信号，野生goroutine何时退出不确定）

这种情况可以采用worker模型，预先创建一批goroutine，它们等待接收任务并进行相应处理。

注意，下面的代码存在一个问题：在取消的时候，channel里还有部分残留的任务没有执行完毕。可以close的方法里进行兜底处理，把所有残留任务处理掉再退出。

```
//名称为cache 执行线程为1 buffer长度为1024
cache := fanout.New("cache", fanout.Worker(1), fanout.Buffer(1024))
cache.Do(c, func(c context.Context) { SomeFunc(c, args...) })
cache.Close()
```

**https://github.com/go-kratos/kratos/blob/v1.0.0/pkg/sync/pipeline/fanout/fanout.go**


```
package goworker

import (
"context"
"errors"
"runtime"
"sync"
)

var (
	// ErrFull chan full.
	ErrFull   = errors.New("fanout: chan full")
)

type options struct {
	worker int
	buffer int
}

// Option fanout option
type Option func(*options)

// Worker specifies the worker of fanout
func Worker(n int) Option {
	if n <= 0 {
		panic("fanout: worker should > 0")
	}
	return func(o *options) {
		o.worker = n
	}
}

// Buffer specifies the buffer of fanout
func Buffer(n int) Option {
	if n <= 0 {
		panic("fanout: buffer should > 0")
	}
	return func(o *options) {
		o.buffer = n
	}
}

type item struct {
	f   func(c context.Context)
	ctx context.Context
}

// Fanout async consume data from chan.
type Fanout struct {
	name    string
	ch      chan item
	options *options
	waiter  sync.WaitGroup

	ctx    context.Context
	cancel func()
}

// New new a fanout struct.
func New(name string, opts ...Option) *Fanout {
	if name == "" {
		name = "anonymous"
	}
	o := &options{
		worker: 1,
		buffer: 1024,
	}
	for _, op := range opts {
		op(o)
	}
	c := &Fanout{
		ch:      make(chan item, o.buffer),
		name:    name,
		options: o,
	}
	c.ctx, c.cancel = context.WithCancel(context.Background())
	c.waiter.Add(o.worker)
	for i := 0; i < o.worker; i++ {
		go c.proc()
	}
	return c
}

func (c *Fanout) proc() {
	defer c.waiter.Done()
	for {
		select {
		case t := <-c.ch:
			wrapFunc(t.f)(t.ctx)
		case <-c.ctx.Done():
			return
		}
	}
}

func wrapFunc(f func(c context.Context)) (res func(context.Context)) {
	res = func(ctx context.Context) {
		defer func() {
			if r := recover(); r != nil {
				buf := make([]byte, 64*1024)
				buf = buf[:runtime.Stack(buf, false)]
			}
		}()
		f(ctx)
	}
	return
}

// Do save a callback func.
func (c *Fanout) Do(ctx context.Context, f func(ctx context.Context)) (err error) {
	if f == nil || c.ctx.Err() != nil {
		return c.ctx.Err()
	}

	//todo context.Background() is eg.
	nakeCtx := context.Background()

	select {
	case c.ch <- item{f: f, ctx: nakeCtx}:
	default:
		err = ErrFull
	}
	return
}

// Close close fanout
func (c *Fanout) Close() error {
	if err := c.ctx.Err(); err != nil {
		return err
	}
	c.cancel()
	c.waiter.Wait()
	return nil
}

```