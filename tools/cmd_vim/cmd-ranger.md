# cmd-ranger

## 1 生成默认配置文件

```
$ ranger --copy-config=all
$ ls ~/.config/ranger
commands.py      commands_full.py rc.conf          rifle.conf       scope.sh

```

* rc.conf：配置文件
* rifle.conf：打开方式
* scope.sh：预览脚本

## 2 快捷键与命令

* `hjkl`：移动光标
* `[`和`]`：移动最左列光标。
* `r`：操作光标选中文件或目录。
* `H`和`L`：跳转上次光标位置或进行反向跳转。
* `<ctrl>h`：切换显示隐藏文件
* `o`：文件或目录排序
* `/`：搜索文件或目录
* `f`：查找文件或目录并跳转
* `<shift>s`：退出ranger跳转到中间列所在目录
* `;shell xxx` 或 `:shell xxx` ：执行shell命令 xxx。
* `eU`：查看当前目录中文件大小
* `yp`：yank path
* `yy`：复制文件目录
* `dd`：剪切文件目录
* `dD`：删除文件目录
* `pp`：粘贴文件目录。（po是覆盖粘贴）
* `w`：进入任务管理器，此时按dd取消任务

**批量重命名命令**

* `:bulkrename`

## 3 自定义配置

```
set vcs_aware true
set preview_images true
set preview_images_method iterm2

#修改删除操作，使用trash-cli
map dD shell trash %s
map dT shell trash %s
map <DELETE>   trash %s
```

## 4 troubleshotting

预览文件时卡顿死掉，社区里暂未解决，关掉预览文件功可规避该问题。

```
set preview_files false
```
