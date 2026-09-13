#!./liquidsoap
# header
s = input.ffmpeg(format="lavfi", "sine=frequency=440")
# footer
output(s)
