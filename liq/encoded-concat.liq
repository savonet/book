#!/usr/bin/env liquidsoap
s   = playlist(loop=false, "~/Music")
fmt = %ffmpeg(format="mp3", %audio.copy, %video.none)
output.file(fallible=true, fmt, "/tmp/out.mp3", s)
