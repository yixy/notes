# 词法分析器生成工具-Lex与Flex #

Lex和Flex都是用于创建扫描器（或词法分析器）的工具，这些扫描器可以在编译器中用于识别词法元素。它们接收一个定义的正则表达式集合并生成一个可以接收字符串并返回匹配的标记序列的程序。Lex是Unix的标准词法分析器生成器，由Mike Lesk和Eric Schmidt开发。而Flex（Fast Lexical Analyzer Generator）是Lex的改进版本，由Vern Paxson开发。Flex生成的词法分析器通常比Lex更快，有更好的性能，而且兼容性更好。

Flex输入文件通常由三个部分组成，每部分由一个%%行分隔：

* 定义部分：在这个部分，用户可以声明C语言中的变量，定义宏，以及包含头文件。这些定义在生成的C源文件的顶部，外部链接区域之前。
* 规则部分：这是flex文件的核心部分。在这里，用户可以指定一系列的正则表达式规则和这些规则匹配时执行的C代码。每个规则都有两个部分：一部分是正则表达式，另一部分是当输入匹配这个表达式时执行的C代码。
* 用户子例程部分：在这部分中，用户可以定义任意的辅助函数，这些函数可以在第二部分中的代码段中使用。这部分中的代码将被拷贝到生成的C源文件的底部。

基于上述三部分，Flex生成的C源文件通常可以直接编译并链接到用户的应用程序中，从而使应用程序具有词法分析的能力。

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
//如果是flex则使用gcc lex.yy.c -lfl
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
