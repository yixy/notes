# Fatal记录日志退出的问题

```go
//logrus.Fatal
// Fatal logs a message at level Fatal on the standard logger then the process will exit with status set to 1.
func Fatal(args ...interface{}) {
	std.Fatal(args...)
}
```