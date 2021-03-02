#!/usr/bin/env -S liquidsoap -i
a = sine()
b = video.fill(color=0x0000ff, blank())
s = add([a, b])
output(s)
output.graphics(s)
