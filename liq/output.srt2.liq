#!./liquidsoap
# header
s = playlist("~/Music")
output.srt(fallible=true, mode="listener", %mp3, s)
