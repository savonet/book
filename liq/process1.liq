#!/usr/bin/env liquidsoap
s = single("process:wav,ffmpeg -y -i $(input) -ac 2 $(output):test.mp3")
out(s)