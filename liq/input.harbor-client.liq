#!/usr/bin/env liquidsoap
s = mksafe(playlist("~/Music"))
output.icecast(host="localhost", password="hackme", mount="live",
               %mp3, s)
