# sqlite #

SQLite 是一个开源的嵌入式关系数据库，实现自包容、零配置、支持事务的SQL数据库引擎。其特点是高度便携、使用方便、结构紧凑、高效、可靠。 与其他数据库管理系统不同，SQLite 的安装和运行非常简单，在大多数情况下,只要确保SQLite的二进制文件存在即可开始创建、连接和使用数据库。

Go支持sqlite的驱动也比较多，下面介绍支持database/sql接口的mattn/go-sqlite3。

* https://github.com/mattn/go-sqlite3 支持database/sql接口，基于cgo(关于cgo的知识请参看官方文档或者本书后面的章节)写的
* https://github.com/feyeleanor/gosqlite3 不支持database/sql接口，基于cgo写的
* https://github.com/phf/go-sqlite3 不支持database/sql接口，基于cgo写的

## 1. 系统表 ##

* SQLITE_MASTER

每一个 SQLite 数据库都有一个叫 SQLITE_MASTER 的表， 它定义数据库的模式，存放了table和index元数据。

* sqlite_sequence

sqlite_sequence表也是SQLite的系统表。该表用来保存其他表的RowID的最大值。数据库被创建时，sqlite_sequence表会被自动创建。该表包括两列。第一列为name，用来存储表的名称。第二列为seq，用来保存表对应的RowID的最大值。该值最大值为9223372036854775807。当对应的表增加记录，该表会自动更新。当表删除，该表对应的记录也会自动删除。如果该值超过最大值，会引起SQL_FULL错误。所以，一旦发现该错误，用户不仅要检查SQLite文件所在的磁盘空间是否不足，还需要检查是否有表的ROWID达到最大值。