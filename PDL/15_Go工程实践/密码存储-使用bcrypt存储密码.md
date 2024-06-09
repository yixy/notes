# 密码存储-使用bcrypt存储密码 #

使用慢哈希函数来进行密码存储可以增加其安全性。

bcrypt是专门为密码存储而设计的算法，基于Blowfish加密算法变形而来，由Niels Provos和David Mazières发表于1999年的USENIX。

bcrypt最大的好处是有一个参数（work factor), 可用于调整计算强度，而且work factor是包括在输出的摘要中的。随着攻击者计算能力的提高，使用者可以逐步增大work factor，而且不会影响已有用户的登陆。

bcrypt经过了很多安全专家的仔细分析，使用在以安全著称的OpenBSD中，一般认为它比PBKDF2更能承受随着计算能力加强而带来的风险。bcrypt也有广泛的函数库支持，因此我们建议使用这种方式存储密码。

goalng的bcrypt库，golang.org/x/crypto/bcrypt。

```
package main

import (
    "fmt"
    "golang.org/x/crypto/bcrypt"
)

func main() {

    passwordOK := "admin"
    passwordERR := "adminxx"

    hash, err := bcrypt.GenerateFromPassword([]byte(passwordOK), bcrypt.DefaultCost)
    if err != nil {
        fmt.Println(err)
    }
    //fmt.Println(hash)

    encodePW := string(hash)  // 保存在数据库的密码，虽然每次生成都不同，只需保存一份即可
    fmt.Println(encodePW)

    // 正确密码验证
    err = bcrypt.CompareHashAndPassword([]byte(encodePW), []byte(passwordOK))
    if err != nil {
        fmt.Println("pw wrong")
    } else {
        fmt.Println("pw ok")
    }

    // 错误密码验证
    err = bcrypt.CompareHashAndPassword([]byte(encodePW), []byte(passwordERR))
    if err != nil {
        fmt.Println("pw wrong")
    } else {
        fmt.Println("pw ok")
    }
}
```