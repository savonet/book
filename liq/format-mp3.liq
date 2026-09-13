#!/usr/bin/env liquidsoap
s = mksafe(playlist("~/Music"))
# header
output.file(%mp3, "/tmp/backup.mp3", s)
