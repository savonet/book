#!./liquidsoap
s = playlist(reload=1, reload_mode="rounds", "playlist")
output(s)
