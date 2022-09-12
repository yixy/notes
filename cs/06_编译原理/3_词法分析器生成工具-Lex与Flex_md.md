# 词法分析器生成工具-Lex与Flex #

Flex就是由Vern Paxon实现的一个Lex，Bison则是GNU版本的YACC。

## 1 Lex ##

Lex会生成一个叫做『词法分析器』的程序。其核心是一个（yylex函数），它接收有一个字符流传入参数，词法分析器函数看到一组字符就会去匹配一个关键字(key)，采取相应措施。

```
example.l -->【lex编译器】 --> lex.yy.c --> 【C编译器】 --> a.out

输入流  --> 【a.out】(词法分析器) --> 词法单元序列
```

## 2 Flex ##

一个Flex源程序的一般形式。

```
声明部分：名称声明（名称 定义）及选项设置（%option指定）。另外，该部分中%{和%}之间的内容会被原样复制到生成的C文件开头，实际用于通常放置头文件。
%%
转换规则：正则表达式 {动作}。 正则式采用贪心匹配算法，并且优先匹配更早出现的模式。
%%
辅助函数：包含任意合法的C代码，该部分内容也会复制到生成的C文件中。
```

一个简单的例子。

```
%option yylineno noyywrap
%{
#include <stdio.h>
%}
%%
stop printf("Stop command received\n");
start printf("Start command received\n");
%%
int main(void){
    yylex();
    return 0;
}
```

验证结构。

```
$ lex example.l
$ gcc lex.yy.c -o example -ll
$ ./example
start
Start command received

stop
Stop command received

abcdestartttt
abcdeStart command received
ttt
```

## 参考 ##

http://dinosaur.compilertools.net/#books