#!./liquidsoap
s = playlist("~/Music")
s = ffmpeg.encode.audio(%ffmpeg(%audio(codec="libmp3lame")), s)
s = ffmpeg.decode.audio(s)
output(s)
