#!/usr/bin/env liquidsoap
s = mksafe(playlist("~/Music"))
c = 1
output.file(%mp3(channels=c, bitrate=192), "/tmp/backup.mp3", s)
