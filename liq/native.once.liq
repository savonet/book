#!./liquidsoap
open native
o = once(single("ad.mp3"))
m = playlist("~/Music")
s = fallback([o, m])
output(s)
