# 使用go-oci8连接oracle #

go-oci8是一个第三方开源库，通过oracle提供的OCI来连接oracle数据库。

下面简单介绍下go-oci8配置步骤。具体go语言环境设置如下：

    export GOROOT=/data/go
    export GOPATH=/data/go/work
    export GOBIN=/data/go/work/bin
    export PATH=$PATH:$GOROOT/bin

## 1. 下载并安装OCI ##

详见《oralce客户端安装配置》。安装后OCI环境目录如下：

    ORACLE_HOME=/app/instantclient_11_2
    //其余略

## 2. go-oci下载及配置 ##

设置环境变量：

    export PKG_CONFIG_PATH=/data/go/work/src/github.com/mattn/go-oci8

下载go-oci的zip包并解压到PKG_CONFIG_PATH变量对应路径：

    https://github.com/mattn/go-oci8/archive/master.zip

配置$PKG_CONFIG_PATH/oci8.pc文件：

    prefix=/app/instantclient_11_2
    exec_prefix=${prefix}
    libdir=${prefix}
    includedir=${prefix}/sdk/include/

    glib_genmarshal=glib-genmarshal
    gobject_query=gobject-query
    glib_mkenums=glib-mkenums

    Name: oci8
    Description: oci8 library
    Libs: -L${libdir} -lclntsh
    Cflags: -I${includedir}
    Version: 11.2

## 3. 其它 ##

libclntsh.so.11.2需要做软链接，否则可能提示libclntsh找不到的错误。

go语言1.7之后，golang.org/x/net/context包已经纳入标准，即context。所以oci8.pc中用import的golang.org/x/net/context可以替换成context包。

## 4. 测试 ##

使用$PKG_CONFIG_PATH/example/lastinsertid/main.go进行测试。

    go install github.com/mattn/go-oci8/example/lastinsertid
    cd $GOBIN
    ./main user/passwd@localhost/misorcl

## 5. 补充说明Windows的go-oci8配置 ##

### 5.1 安装TDM-GCC环境 ###

下载二进制文件安装即可。安装路径如下：

    D:\myprogram\tdm-gcc-64

### 5.2 下载安装pkg-config ###

1. go to http://ftp.gnome.org/pub/gnome/binaries/win32/dependencies/
2. download the file pkg-config_0.26-1_win32.zip
3. extract the file bin/pkg-config.exe to D:\myprogram\tdm-gcc-64\bin
4. download the file gettext-runtime_0.18.1.1-2_win32.zip
5. extract the file bin/intl.dll to D:\myprogram\tdm-gcc-64\bin
6. go to http://ftp.gnome.org/pub/gnome/binaries/win32/glib/2.28
7. download the file glib_2.28.8-1_win32.zip
8. extract the file bin/libglib-2.0-0.dll to D:\myprogram\tdm-gcc-64\bin

### 5.3 下载并安装OCI ###

与linux类似，不赘述。注意点详见《oralce客户端安装配置》关于windows安装的说明。

### 5.4 配置go-oci8###

配置oci8.pc文件如下：

    ora=C:/oracle/instantclient_11_2/sdk
    gcc=D:/myprogram/tdm-gcc-64

    oralib=${ora}/lib/gcc
    orainclude=${ora}/include

    gcclib=${gcc}/lib
    gccinclude=${gcc}/include

    glib_genmarshal=glib-genmarshal
    gobject_query=gobject-query
    glib_mkenums=glib-mkenums

    Name: oci8
    Description: Oracle database engine
    Version: 11.2
    Libs: -L${oralib} -L${gcclib} -loci
    Libs.private:
    Cflags: -I${orainclude} -I${gccinclude}

### 5.5 测试###

测试oracle连接报如下错误：

    In file included from C:/instantclient_11_2/sdk/include/oci.h:535:0,from src\github.com\wendal\go-oci8\oci8.go:4:C:/instantclient_11_2/sdk/include/oratypes.h:236:25: error: expected '=', ',', ';', 'asm' or 'attribute' before 'ubig_ora' typedef unsigned _int64 ubig_ora;

修改oci包含的头文件oratypes.h中对应两处_int64为__int64后（在前添加下划线）解决。
