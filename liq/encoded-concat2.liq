#!/usr/bin/env liquidsoap
s   = playlist(loop=false, "~/Music")
# s   = playlist(loop=false, "playlist2")
s   = clock(sync="none", s)
fmt = %ffmpeg(format="mp3", %audio.copy)
# , %video.none)
# , on_stop=shutdown
output.file(fallible=true, fmt, "/tmp/out.mp3", s)
