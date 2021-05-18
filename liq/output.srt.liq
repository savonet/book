#!./liquidsoap
s = playlist("~/Music")
output.srt(fallible=true, host="localhost", %wav, s)
