#!/usr/bin/env liquidsoap
s = add([sine(), video.fill(color=0x0000ff, blank())])
output(s)
output.graphics(s)
