# vim-快捷键 #

vim有normal、edit、visual三种模式。

在normal模式可使用快捷键。

**执行shell**

* `:!echo 123`

**光标移动**

* `h`：光标向左移动
* `j`：光标向上移动
* `k`：光标向下移动
* `l`：光标向右移动
* `w`：移动到下一个word的开头
* `b`：back word，移动到上一个word的开头
* `0`：光标移动到行首
* `$：光标移动到行`尾
* `gg`：移动到文件开头
* `G`：跳转到文件结尾
* `(xx)G`：跳转到行，例如18G跳转到18行
* `ctrl+o`：光标返回到上一个位置
* `ctrl+i`：与ctrl+o配合使用，光标返回到上一个位置
* 使用`:jumps`命令可以查看跳转表
* `ctrl+d`：forward，向下翻1/2页
* `ctrl+u`：upward，向上翻1/2页
* `{` `}` (进行段落的跳转) 
* `f` (跳转到接下来出现的某个字符) 
* `%` （跳到相匹配的括号)

**进入visual模式**

* `v`：visual，进行文本选择
* `<shift>+v`：visual行模式
* `<shift>+v+g`：visual行模式，选中到最后一行
* `<ctrl>+v`：visual块模式

visual模式下使用normal模式命令

* `normal itest`：光标后插入字符串test

**进入edit模式：新增**

* `a`：append，光标后插入
* `i`：insert，光标前插入
* `o`：open a line，在光标所在行的下方打开一个新行
* `A`：行后插入
* `I`：行前插入
* `O`：光标所在行上方打开一个新行

**进入edit模式：修改**

* `c`：change，
* `ciw`：change inner word，
* `ci"`：修改双引号内的内容
* `ct)`：修改到右括弧

**删除**

* `x`：删除一个字符
* `dd`：删除一行
* `dw`：delete word，删除光标后面的word及其空白字符
* `daw`：delete around word，删除整个word及其后空白字符
* `diw`：delete inner word，删除整个word，不包括其后的空白字符
* `df`: 以dfs为例，删除从光标处到字符s（含）的字符，单行操作
* `d3h`: 删除光标左侧3个字符
* `d3l`: 删除光标右侧3个字符

注意，编辑模式下，ctrl+w快捷键可以进行光标前到word删除

**查询**

* `f`：find，在本行光标后查询字符，例如fs代表查询字符s。分号代表查找下一处
* `F`：在本行光标前查询字符，例如fb代表查询字符b。分号代表查找下一处
* `/`：向下查询单词
* `?`：向上查询单词

**撤销**

* `u`：undo，撤销操作

**复制粘贴**

* `y`：yank
* `p`：paste，
* `yf`：以yfs为例，复制从光标处到字符s（含）的字符，单行操作
* `d3h`： 删除光标左侧3个字符
* `d3l`：【 删除光标右侧3个字符

**其它**

* `gf`： goto file，打开光标位置的文件
