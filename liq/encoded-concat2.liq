#!/usr/bin/env liquidsoap
s   = playlist(loop=false, "~/Music")
s   = clock(sync="none", s)
fmt = %ffmpeg(format="mp3", %audio.copy)
output.file(fallible=true, on_stop=shutdown, fmt, "/tmp/music.mp3", s)
