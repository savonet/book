#!./liquidsoap
s = playlist(reload=3600, reload_mode="seconds", "playlist")
output(s)
