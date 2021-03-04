#!/usr/bin/env liquidsoap
s = mksafe(playlist("~/Music"))
b = 192
output.file(%mp3(mono, bitrate=b), "/tmp/backup.mp3", s)