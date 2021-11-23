#!/usr/bin/env liquidsoap
server.telnet()
s = playlist(id="music", "~/Music")
output(s)
