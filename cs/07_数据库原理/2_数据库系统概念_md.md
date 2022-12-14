# 数据库系统概念 #

## 1 数据库系统 ##

<img src="数据库系统.png" alt="100%" width="100%">

从下往上看这张图。

图中的下半部分实际上就描述了一个数据库系统。典型的，关系型数据库中存放的就是表数据。

* 数据库：一个相互关联的数据信息的集合，它们被以一定方式存储在一起。用户可以对数据库中的数据进行新增、修改、删除、查询等操作。(Database: A database is an organized collection of inter-related data that models some aspect of the real-world.)
* 数据库管理系统（DBMS）：为管理数据库而设计的计算机软件管理系统。DBMS不仅负责对数据的管理（定义信息存储结构，提供信息查询机制，数据库的存储及事务处理），还必须提供所存储信息的安全性保证。(A DBMS is software that allows applications to store and analyze information in a database.)
* 数据库系统：指数据库、DBMS、数据库管理员（DBA）、数据库应用程序（DBAP）等构成的系统。

图中的中间部分描述了DBA如何使用数据库语言通过DBMS去定义、查询及管理维护数据库，以及开发人员如何使用数据库语言来进行数据库应用程序开发。对于不掌握数据库语言的最终用户，可以通过编写的数据库应用程序（DBAP）来使用数据库。数据库语言包含DDL和DML。数据库定义和数据操纵语言并不是两种分离的语言，相反，它们简单地构成了单一的数据库语言的一部分，比如广泛使用的SQL语言。

* 数据定义语言（data-definition language）：DDL，用于定义数据库模式（数据存储定义、约束、授权等，DDL的输出作为数据库元素被放到数据库的数据字典中）。
* 数据操作语言（data-manipulation language）：DML，用于表达数据库查询和更新（增删改查）。

图中的上半部分描述了数据库的设计过程，指导怎样由现实世界到信息世界，再到计算机世界，进行抽象建模和设计。（为什么要有设计过程？以关系型数据库为例，因为需要解决数据库定义哪些表，这些表是怎么抽象出来的，为什么要定义这些表。）数据库的设计主要包含概念设计和逻辑设计两个阶段。

* 概念设计（数据建模/抽象）：将真实世界的问题转换为概念模型，重点在于描述数据以及它们之间的关系，通常使用ER图或规范化算法等方法来实现（抽象出E-R图）。
* 逻辑设计：将高层的概念模式映射到要使用的数据库实现数据模型上（定义出数据模式）。

## 2 学习数据库系统概念需要关注的主要内容 ##

基于上述数据库相关的基本概念，将需要重点关注的内容分为以下几块，并进行逐一介绍。

* 数据库设计：理解数据-数据模式-数据模型，学习关系模型，学习ER模型，学习数据库设计方法（概念设计、逻辑设计）
* 数据库语言：包括DDL和DML，学习最常用的SQL语言
* DBMS实现技术：数据库的存储、查询、事务控制实现原理