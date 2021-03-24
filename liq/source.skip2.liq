#!/usr/bin/env liquidsoap
set("server.telnet", true)
s = playlist(id="music", "~/Music")
output(s)
