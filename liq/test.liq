#!./liquidsoap
s = playlist("~/Music")
s = fade.out(duration=5., track_sensitive=false, s)
output(s)
