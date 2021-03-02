#!/usr/bin/env liquidsoap
# Trying to amplify encoded audio
s = playlist(loop=false, "~/Music")
s = amplify(3., s)
output.file(fallible=true, %ffmpeg(format="mp3", %audio.copy), "/tmp/out.mp3", s)
