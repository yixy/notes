# 会话管理-gorilla #

https://github.com/gorilla/sessions/blob/master/doc.go

`session,err:=sessions.Get(request,"session-name")`根据request中cookie信息(key是常量字符串session-name，值是cookie["session-name"])解码生成对应的SessionID，通过后基于SessionID返回一个服务端store里的session（如果服务端store里为空则新创建并返回session，新创建的session暂时不在store中，待调用Save后才会写入store）。

以NewFilesystemStore为例，若解码获取SessionID成功，此时已有storeFile，则session.IsNew为true，返回session即为服务端store里对应session，否则session.IsNew为false，返回session为新session。`session.Save(request,response)`将session写入或更新到服务端store。在save调用前，若设置`session.Options.MaxAge`为负值，那么在调用Save时，如果session.IsNew为true（session在store中）则会删除store中对应session并设置cookie的超时时间，如果session.IsNew为false（session不在store中）则会产生`remove cookie file`报错。


```
//secret key
SecretStr := util.RandomString(32)
Secret := []byte(SecretStr)
var store = sessions.NewFilesystemStore("", env.Secret)

sessionCookieName   = "session"
sessionValidFlag    = "isValid"

//login
g.POST("/v1/sessions", func(c echo.Context) error {
	username := c.FormValue("username")
	password := c.FormValue("password")

	// Throws unauthorized error
	if username != "foo" || password != "bar" {
		return echo.ErrUnauthorized.Internal
	}

	sess, err := session.Get(sessionCookieName, c)
	if err != nil {
		return err
	}
	sess.Values["name"] = username
	sess.Values[sessionValidFlag] = true
	err = sess.Save(c.Request(), c.Response())
	if err != nil {
		return err
	}
	return c.String(http.StatusOK, "Hello, World!")
})

//session check exclude login
var sessionGet = func(c echo.Context) (*sessions.Session, error) {
	sess, err := session.Get(sessionCookieName, c)
	if err != nil {
		return nil, err
	}
	if isVlalid, ok := sess.Values[sessionValidFlag].(bool); !ok || !isVlalid {
		return nil, errors.New("the sessionID is invalid")
	}
	return sess, err
}

//logout
g.DELETE("/v1/sessions/:name", func(c echo.Context) error {
	sess, err := sessionGet(c)
	if err != nil {
		return err
	}
	sess.Values[sessionValidFlag] = false
	sess.Options.MaxAge = -1
	err = sess.Save(c.Request(), c.Response())
	if err != nil {
		return err
	}
	return c.String(http.StatusOK, "logout!")
})

//test handle
g.POST("/v1/test", func(c echo.Context) error {
	sess, err := sessionGet(c)
	if err != nil {
		return err
	}
	isVlalid, ok := sess.Values[sessionValidFlag].(bool)
	if !ok {
		return errors.New("the sessionID in Cookie is Expired")
	}
	if isVlalid {
		zap.Logger.Info("Vlalid")
	} else {
		zap.Logger.Info("inVlalid")
	}
	return c.String(http.StatusOK, "ok")
})
```