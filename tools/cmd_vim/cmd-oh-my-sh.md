# cmd-oh-my-sh.md #

## 1 install ##

跟Bash相比，Zsh的补全功能强大了许多，可以自动补全命令、参数、文件名、进程、用户名、变量、权限符等等。另外，Zsh还支持插件扩展。因为 zsh 的默认配置极其复杂繁琐，让人望而却步。Oh My Zsh是一个方便你配置和使用Zsh的一个开源工具项目，让zsh配置降到0门槛。而且它完全兼容 bash 。

检查是否已安装zsh：

```
cat /etc/shells
#如果没有则进行安装
brew install zsh
```

接下来安装OhMyZsh，具体参考官网说明：

```
http://ohmyz.sh/
```

默认安装过后，使用的是robbyrussell主题。可以在`https://github.com/ohmyzsh/ohmyzsh/wiki/Themes`找到一款喜欢的主题，把主题文件下载到 ~/.oh-my-zsh/themes 里面，然后修改 ~/.zshrc 文件，配置好主题名字即可：

```
ZSH_THEME="ys"
```

把默认的Shell改成zsh

```
chsh -s /bin/zsh
```

## 2. oh-my-zsh使用姿势 ##

* 进程id补全：Zsh的补全功能非常不错，除了一般的目录和文件名补全，还可以自动补全进程ID。比如，要kill掉一个进程，得先用 ps -aux|grep process_name 先拿到进程id，然后再 kill process_name 来终止掉一个进程。
* 快速跳转：Zsh支持目录的快速跳转，我们可以使用 d 这个命令，列出最近访问过的各个目录，然后选择目录前面的数字进行快速跳转。
* 目录名简写与补全：如果确切的知道我们要进入某一层目录，但是目录名比较长，没关系，Zsh帮你搞定！ 比如我们要进入到 /workspace/src/dict，我们只需要输入每个目录的首字母wsd就行，然后再TAB键补全，Zsh会帮你搞定剩下的。
* 重复上一条命令：输入 r ，可以很便捷的重复执行上一条命令。

## 3. 使用oh-my-zsh插件 ##

以auto-suggestions plugin插件为例进行介绍，该插件用于命令行自动提示补全。

> If you press the → key (forward-char widget) or End (end-of-line widget) with the cursor at the end of the buffer, it will accept the suggestion, replacing the contents of the command line buffer with the suggestion.

下载安装步骤如下：

1. Clone this repository into $ZSH_CUSTOM/plugins (by default ~/.oh-my-zsh/custom/plugins)
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

2. Add the plugin to the list of plugins for Oh My Zsh to load (inside ~/.zshrc):
plugins=(zsh-autosuggestions)

3. Start a new terminal session.
