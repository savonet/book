#!/usr/bin/env liquidsoap
s = mksafe(playlist("~/Music"))
output.icecast(%mp3,
  host="localhost", password="hackme", mount="live", s)
