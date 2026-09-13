#!./liquidsoap
# header
s = single("artist:Sinatra")
# footer
output(mksafe(s))
