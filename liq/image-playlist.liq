#!./liquidsoap
# header
s = playlist(prefix="annotate:duration=2:", "image.playlist")
# footer
output.video(s)
