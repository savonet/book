#!/usr/bin/env liquidsoap
s   = playlist(loop=false, "~/Music")
clock.assign_new(sync="none", [s])
fmt = %ffmpeg(format="mp3", %audio.copy)
o   = output.file(fallible=true, fmt, "/tmp/music.mp3", s)
o.on_stop(synchronous=false, shutdown)
