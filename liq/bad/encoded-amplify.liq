#!./liquidsoap -i
s = playlist(loop=false, "~/Music")
t = amplify(3., s)
u = ffmpeg.decode.audio(t)
output(u)
