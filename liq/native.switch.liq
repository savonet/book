#!./liquidsoap
open native
s = sine(amplitude=0.2)
m = playlist("~/Music")
s = switch(track_sensitive=false, [({time() mod 2. <= 1.}, s), ({true}, m)])
output(s)
