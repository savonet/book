#!/usr/bin/env liquidsoap
# header
server.telnet()
s = playlist(id="music", "~/Music")
output(s)
