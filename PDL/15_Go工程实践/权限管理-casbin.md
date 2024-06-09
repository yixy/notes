# 权限管理-casbin #

https://casbin.org/docs/zh-CN/overview

使用casbin的RBAC模式的例子。


Model CONF 至少应包含四个部分: `[request_definition], [policy_definition], [policy_effect], [matchers]`。如果 model 使用 RBAC, 还需要添加`[role_definition]`部分。Model CONF 文件可以包含注释。注释以 # 开头， # 会注释该行剩余部分。

```
#rbac_model.conf

#[request_definition] 部分用于request的定义，它明确了 e.Enforce(...) 函数中参数的含义。
[request_definition]
r = sub, obj, act

#[policy_definition] 部分是对policy的定义，以下文的 model 配置为例:
[policy_definition]
p = sub, obj, act

[role_definition]
g = _, _

#[policy_effect] 是策略效果的定义。 它确定如果多项政策规则与请求相符，是否应批准访问请求。
[policy_effect]
e = some(where (p.eft == allow))

#[matchers] 是策略匹配程序的定义。匹配程序是表达式。它定义了如何根据请求评估策略规则。
[matchers]
m = g(r.sub, p.sub) && r.obj == p.obj && r.act == p.act
```


```
#rbac_policy.csv
p, alice, data1, read
p, bob, data2, write
p, data2_admin, data2, read
p, data2_admin, data2, write
g, alice, data2_admin
```