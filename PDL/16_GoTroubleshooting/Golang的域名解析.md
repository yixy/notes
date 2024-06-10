# Golang的域名解析 #

## 1. 概述 ##

**golang有两种域名解析方法：内置Go解析器；基于cgo的系统解析器。**

```
var lookupOrderName = map[hostLookupOrder]string{
    hostLookupCgo:      "cgo",
    hostLookupFilesDNS: "files,dns",
    hostLookupDNSFiles: "dns,files",
    hostLookupFiles:    "files",
    hostLookupDNS:      "dns",
}
```

其中hostLookupCgo是一类，表示直接调用libc的getaddrinfo方法去解析。

其它四个是另一类，表示go去读取文件/etc/hosts和/etc/resolv.conf去解析，files表示先看看/etc/hosts有没有对应的记录，dns表示通过/etc/resolv.conf的server去解析。四个指定了不同的解析方式顺序。

goos为darwin和android的平台都是用cgo解析，这是因为这两个平台上找不到/etc/hosts和/etc/resolv.conf文件。对应linux都是使用purego去解析的。然后先files还是先dns的关系是使用/etc/nsswitch.conf的配置的。

如果你确定你机器上有/etc/hosts和/etc/resolv.conf这两个文件，而且格式正确，应用程序有访问权限，那个你可以设置Resovler.PreferGo=true，强制使用purego。另外，貌似也可以通过环境变量GODEBUG来配置。

```
#可以通过环境变量GODEBUG来配置。
export GODEBUG=netdns=go    # force pure Go resolver
export GODEBUG=netdns=cgo   # force cgo resolver
```

## 2. 源码分析 ##

默认采用的是内置Go解析器，因为当DNS解析阻塞时，内置Go解析器只是阻塞了一个goroutine，而cgo的解析器则是阻塞了一个操作系统级别的线程。

```
func init() { netGo = true }
```

但是注意，读取 `/etc/resolv.conf `失败则强制使用cgo。所以goos为darwin和android的平台都是用cgo解析，这是因为这两个平台上找不到//etc/resolv.conf文件。

```
	confVal.resolv = dnsReadConfig("/etc/resolv.conf")
	if confVal.resolv.err != nil && !os.IsNotExist(confVal.resolv.err) &&
		!os.IsPermission(confVal.resolv.err) {
		// If we can't read the resolv.conf file, assume it
		// had something important in it and defer to cgo.
		// libc's resolver might then fail too, but at least
		// it wasn't our fault.
		confVal.forceCgoLookupHost = true
	}
```

当 /etc/nsswitch.conf 文件不存在或者文件存在但是没有指定 hosts 字段时，linux下使用的是 hostLookupDNSFiles ，也就是说，dns解析优先hosts解析。

```
	nss := c.nss
	srcs := nss.sources["hosts"]
	// If /etc/nsswitch.conf doesn't exist or doesn't specify any
	// sources for "hosts", assume Go's DNS will work fine.
	if os.IsNotExist(nss.err) || (nss.err == nil && len(srcs) == 0) {
		if c.goos == "linux" {
			// glibc says the default is "dns [!UNAVAIL=return] files"
			// http://www.gnu.org/software/libc/manual/html_node/Notes-on-NSS-Configuration-File.html.
			return hostLookupDNSFiles
		}
		return hostLookupFilesDNS
    }
```

通过 nsswitch.conf 可以指定解析顺序。代码挺简单的。


```
	var mdnsSource, filesSource, dnsSource bool
	var first string
	for _, src := range srcs {
		if src.source == "files" || src.source == "dns" {
			if !src.standardCriteria() {
				return fallbackOrder // non-standard; let libc deal with it.
			}
			if src.source == "files" {
				filesSource = true
			} else if src.source == "dns" {
				dnsSource = true
			}
			if first == "" {
				first = src.source
			}
			continue
		}
		// Some source we don't know how to deal with.
		return fallbackOrder
	}

	// Cases where Go can handle it without cgo and C thread
	// overhead.
	switch {
	case filesSource && dnsSource:
		if first == "files" {
			return hostLookupFilesDNS
		} else {
			return hostLookupDNSFiles
		}
	case filesSource:
		return hostLookupFiles
	case dnsSource:
		return hostLookupDNS
	}
```

所以指定 hosts: files dns，解析策略就是 hostLookupFilesDNS，即优先使用 /etc/hosts 。


