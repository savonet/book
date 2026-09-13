#!./liquidsoap
# header
s = playlist(reload=1, reload_mode="rounds", "playlist")
# footer
output(s)
