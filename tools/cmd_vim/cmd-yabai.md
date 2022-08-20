# cmd-yabai

使用yabai需要关闭mac的SIP。

```
# 查看系统完整性保护”机制（SIP）
csrutil status

# 重启MAC，按住cmd+R直到屏幕上出现苹果的标志和进度条，进入Recovery模式；在屏幕最上方的工具栏找到实用工具（左数第3个），打开终端，输入：csrutil disable；关掉终端，重启mac；
csrutil disable
```

安装和启动yabai。

```
#安装 yabai
brew tap koekeishiya/formulae
brew install yabai
sudo yabai --install-sa

#安装快捷键支持:
brew install koekeishiya/formulae/skhd

拷贝默认配置
curl https://raw.githubusercontent.com/koekeishiya/yabai/master/examples/yabairc --output ~/.yabairc
curl https://raw.githubusercontent.com/koekeishiya/yabai/master/examples/skhdrc --output ~/.skhdrc

#启动服务
brew services start skhd
brew services start yabai
```

相关配置。

```
vim ~/.skhdrc

# open terminal
# cmd - return : /Applications/iTerm2.app

# float / unfloat window and fill in screen
 alt - t : yabai -m window --toggle float;\
           yabai -m window --grid 1:1:0:0:1:1


# focus window(同一个空间切换窗口焦点)
alt - h : yabai -m window --focus west
alt - j : yabai -m window --focus south
alt - k : yabai -m window --focus north
alt - l : yabai -m window --focus east

# swap window(同一个空间调整窗口位置)
shift + alt - h : yabai -m window --swap west
shift + alt - j : yabai -m window --swap south
shift + alt - k : yabai -m window --swap north
shift + alt - l : yabai -m window --swap east

```

重启服务。

```
brew services restart skhd
brew services restart yabai
```
