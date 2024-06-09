# 熔断限流-time包下的令牌桶限流 #

其实 Golang 标准库中就自带了限流算法的实现，即 golang.org/x/time/rate。该限流器是基于 Token Bucket(令牌桶) 实现的。

```
//第一个参数是 r Limit。代表每秒可以向 Token 桶中产生多少 token。Limit 实际上是 float64 的别名。
//第二个参数是 b int。b 代表 Token 桶的容量大小。
limiter := NewLimiter(10, 1);
//除了直接指定每秒产生的 Token 个数外，还可以用 Every 方法来指定向 Token 桶中放置 Token 的间隔，例如：
limit := Every(100 * time.Millisecond);
limiter := NewLimiter(limit, 1);
```

## Wait/WaitN ##

```
func (lim *Limiter) Wait(ctx context.Context) (err error)
func (lim *Limiter) WaitN(ctx context.Context, n int) (err error)
```

Wait 实际上就是 WaitN(ctx,1)。

当使用 Wait 方法消费 Token 时，如果此时桶内 Token 数组不足 (小于 N)，那么 Wait 方法将会阻塞一段时间，直至 Token 满足条件。如果充足则直接返回。

这里可以看到，Wait 方法有一个 context 参数。
我们可以设置 context 的 Deadline 或者 Timeout，来决定此次 Wait 的最长时间。

## Allow/AllowN ##

```
func (lim *Limiter) Allow() bool
func (lim *Limiter) AllowN(now time.Time, n int) bool
```

Allow 实际上就是 `AllowN(time.Now(),1)`。

AllowN 方法表示，截止到某一时刻，目前桶中数目是否至少为 n 个，满足则返回 true，同时从桶中消费 n 个 token。
反之返回不消费 Token，false。

通常对应这样的线上场景，如果请求速率过快，就直接丢到某些请求。


## Reserve/ReserveN ##


```
func (lim *Limiter) Reserve() *Reservation
func (lim *Limiter) ReserveN(now time.Time, n int) *Reservation
```

Reserve 相当于 ReserveN(time.Now(), 1)。

ReserveN 的用法就相对来说复杂一些，当调用完成后，无论 Token 是否充足，都会返回一个 Reservation * 对象。

你可以调用该对象的 Delay() 方法，该方法返回了需要等待的时间。如果等待时间为 0，则说明不用等待。
必须等到等待时间之后，才能进行接下来的工作。

或者，如果不想等待，可以调用 Cancel() 方法，该方法会将 Token 归还。

举一个简单的例子，我们可以这么使用 Reserve 方法。

```
r := lim.Reserve()
f !r.OK() {
    // Not allowed to act! Did you remember to set lim.burst to be > 0 ?
    return
}

time.Sleep(r.Delay())
Act() // 执行相关逻辑

```