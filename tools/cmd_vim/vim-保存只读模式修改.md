# vim-保存只读模式修改 #

!用于执行shell命令。tee接受w命令输出，%指定当前文件。

```
:w !sudo tee %
```