#!/usr/bin/env liquidsoap
s = playlist(loop=false, "~/Music")
clock.assign_new(sync="none", [s])
o = output.file(fallible=true, %mp3, "/tmp/out.mp3", s)
o.on_stop(synchronous=false, shutdown)
