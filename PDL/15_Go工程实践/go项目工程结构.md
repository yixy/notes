# go项目工程结构 #

建议通过统一的公共组件来生成项目代码结构。

一个例子如下，注意这不是官方推荐的项目结构。`https://github.com/golang-standards/project-layout`

```
｜——cmd
｜        ｜——myapp1	//本项目的主干。每个应用程序的目录名应该与你想要的可执行文件的名称相匹配
｜                ｜——myapp1
｜                ｜——main.go
｜        ｜——myapp2
｜——internal	//不开放给外部使用的公共代码
｜        ｜——myprivatelib
｜——pkg		//可供外部使用的公共代码
｜        ｜——mypubliclib
｜——api		//OpenAPI/Swagger 规范，JSON 模式文件，协议定义文件。
｜——web		//特定于 Web 应用程序的组件:静态 Web 资产、服务器端模板和 SPAs
｜——configs	//配置文件模板或默认配置。
｜——init		//System init(systemd，upstart，sysv), process manager/supervisor(runit，supervisor)配置。
｜——scripts		//执行各种构建、安装、分析等操作的脚本。
｜——build		//打包和持续集成
｜——deployments	//IaaS、PaaS、系统和容器编排部署配置和模板
｜——test		//额外的外部测试应用程序和测试数据。
｜——docs		//设计和用户文档
｜——example	//应用程序示例。
｜——tool		//项目中使用的支持工具
｜——third_party	//外部辅助工具，分叉代码和其他第三方工具(例如 Swagger UI)。
｜——owner
｜——githooks
｜——assets		//与存储库一起使用的其他资产(图像、徽标等)。
｜——README.md
```