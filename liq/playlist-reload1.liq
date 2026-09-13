#!./liquidsoap
# header
s = playlist(reload=3600, reload_mode="seconds", "playlist")
# footer
output(s)
