#!./liquidsoap
video.frame.rate := 50
frame.duration := 0.02
s = playlist("~/Music")
s = amplify({ (s.time() mod 1. <= 0.02) ? 0. : 1. }, s)
output(s)
