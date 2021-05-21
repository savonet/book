#!/usr/bin/env liquidsoap
s = playlist(loop=false, "~/Music")
s = clock(sync="none", s)
output.file(fallible=true, on_stop=shutdown, %mp3, "/tmp/out.mp3", s)
