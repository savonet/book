#!/usr/bin/env liquidsoap
# header
s = mksafe(playlist("~/Music"))
output.icecast(host="localhost", password="hackme", mount="live",
               %mp3, s)
