# Monotonic Clocks #

https://github.com/bwmarrin/snowflake/pull/18

> Starting from Go 1.9, the standard time package transparently uses Monotonic Clocks when available. Let's use that for generating ids to safeguard against wall clock backwards movement which could be caused by time drifts or leap seconds.

> https://pkg.go.dev/time#hdr-Monotonic_Clocks