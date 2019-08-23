#!/usr/bin/env liquidsoap
set("log.level",6)
s = single("process:wav,echo '$(input)' | text2wav > $(output):Hello world!")
out(s)