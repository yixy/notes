# vim-常用配置

vim配置文件在`~/.vimrc`

```
$ cp -r /usr/share/vim/vimrc ~/.vimrc
$ vim ~/.vimrc

```

刷新vimrc配置命令（注意，该命令只能刷新增加的配置，不能刷新删除的配置。删除配置需要保存退出后重新登录

```
:source ~/.vimrc
```

## 1. 开启语法高亮 

```
syntax on
```

## 2. 高亮配色方案 

查看系统自带的配色方案：

```
$ ls /usr/share/vim/vim80/colors
README.txt    delek.vim     industry.vim  pablo.vim     slate.vim
blue.vim      desert.vim    koehler.vim   peachpuff.vim torte.vim
darkblue.vim  elflord.vim   morning.vim   ron.vim       zellner.vim
default.vim   evening.vim   murphy.vim    shine.vim
```

系统自带配色方案添加自己的用户目录下：

```
cp -r /usr/share/vim/vim80/* ~/.vim
```

或者使用第三方的插件配色方案：（参见插件配置相关内容）

```
colorscheme molokai
hi Visual ctermbg=30

"终端支持256种颜色
set t_Co=256
```

## 3 键位映射 

```
#noremap for no Recursion
#map

map S :w<CR>
map s <nop>

map Q :q<CR>

map R :source $MYVIMRC<CR>
```

## 4 基本配置 

```
"显示行号
set number

set wrap

"当前行显示高亮线
set cursorline

"展示输入的命令
set showcmd

"补全时排序
set wildmenu


"高亮显示/的搜索到的内容
set hlsearch
"光标立刻跳转到/的搜索到的内容
set incserach
"xxx时关闭/的搜索高亮
exec "nohlsearch"
"搜索大小写敏感
set ignorecase
"搜索大小写智能匹配
set smartcase
"配置空格回车触发关闭/的搜索高亮
let mapleader=" "
noremap <LEADER><CR> :nohlsearch<CR>

"兼容vi，会有问题，先关闭
set nocompatible

"文件类型检测和文件缩紧文件装载
filetype on
filetype indent on
filetype plugin on
filetype plugin indent on

"开启鼠标
set mouse=a
set encoding=utf-8
"适配解决不同环境color问题
let &t_ut=''


"tabstop 选项只修改 tab 字符的显示宽度，不修改按 Tab 键的行为
set tabstop=2
"expandtab 选项把插入的 tab 字符替换成特定数目的空格。具体空格数目跟 tabstop 选项值有关
set expandtab
"softtabstop 选项修改按 Tab 键的行为，不修改 tab 字符的显示宽度。具体行为跟 tabstop 选项值有关
set softtabstop=2
"自动缩进所使用的空白长度指示的。
set shiftwidth=2

"显示不可见字符
set list
"设置不可见字符显示模式
set listchars=tab:▸\ ,trail:▫

"光标下方总是保留5行展示
set scrolloff=5
"vim默认为vim配置脚本设置textwidth为78,当输入超过78个字符并按下空格键时会自动换行.将textwidth设成0关闭该功能
set tw=0
"缩进风格
set indentexpr=
"行首按退格键能到上一行尾
set backspace=indent,eol,start
"折叠方法
set foldmethod=indent
set foldlevel=99

"normal和edit模式下光标效果区分
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

"总是显示状态行
set laststatus=2

"vim以当前文件的目录为工作目录
set autochdir

"打开文件时光标保持在上次编辑位置
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

"设定timeout，避免esc需要按两次
set timeoutlen=200

map <LEADER><LEADER> <ESC>/<++><CR>:nohlsearch<CR>c4l
```

## 5. 插件配置 

选择vim-plug这款插件管理器。

```
#https://github.com/junegunn/vim-plug
#Download plug.vim and put it in the "autoload" directory.

# vim
$ curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# nvim
$ sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

```

在vimrc中配置插件，Reload .vimrc and :PlugInstall to install plugins。插件会自动下载安装。

```
call plug#begin('~/.vim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'tomasr/molokai'
call plug#end ()
```

## 6 分屏与tab配置 

```
"设定光标所在屏，并打开分屏
map sl :set splitright<CR>:vsplit<CR>
map sh :set nosplitright<CR>:vsplit<CR>
map sk :set nosplitbelow<CR>:split<CR>
map sj :set splitbelow<CR>:split<CR>

"光标在分屏间移动
map <LEADER>l <C-W>l
map <LEADER>k <C-w>k
map <LEADER>h <C-w>h
map <LEADER>j <C-W>j

"调整主屏大小
map <up> :res +5<CR>
map <down> :res -5<CR>
map <left> :vertical resize-5<CR>
map <right> :vertical resize+5<CR>

"垂直分屏和非垂直分屏相互切换
map sv <C-w>t<C-w>H
map snv <C-w>t<C-w>K

"创建tab以及tab切换
map ta :tabe<CR>
map th :-tabnext<CR>
map tl :+tabnext<CR>
```

## 7 粘贴版 

你的 Vim Build 没有支持 clipboard，那么无论怎样配置都不会生效。 可以用如下命令检查：

```
vim --version | grep clipboard
```

如果输出包含 +clipboard 或 +xterm_clipboard 就支持，如果这两项都是 - 则不支持。例如我的 Vim 输出为（MacOS 上的 macvim）：

```
+clipboard         +keymap            +printer           +vertsplit
+emacs_tags        -mouse_gpm         -sun_workshop      -xterm_clipboard
```

如果你的 Vim 不支持剪切板，则需要重新安装一个带 clipboard 的 Vim：

* MacOS 下可以直接用 brew 安装 macvim，它是支持剪切板的。
* Linux 下，如果是 Debian 或 Ubuntu 可以安装 vim-gtk、vim-gnome，Redhat/CentOS 则可以安装 vim-X11。
* Windows 下比较复杂，可以参考 https://vim.fandom.com/wiki/Using_the_Windows_clipboard_in_Cygwin_Vim。

同步剪切板和匿名寄存器，在 ~/.vimrc 添加配置比如 `set clipboard=unnamed`。

## 8/16进制编辑

开启16进制模式。

```
:%!xxd
```

注意，VIM把这些当做普通的字符串对待，所以，修改了左侧的16进制的字符后右侧的字符并不会跟着改变，反之亦然。注意，只有左侧16进制被修改的部分会生效，对于右侧字符的修改不会产生效果。

修改完成以后，同样在命令行模式下使用以下命令可以返回正常的格式:

```
:%!xxd -r
```

