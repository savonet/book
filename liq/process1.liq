#!/usr/bin/env liquidsoap
# header
s = single("process:wav,ffmpeg -y -i $(input) -ac 2 $(output):test.mp3")
# footer
output(s)
