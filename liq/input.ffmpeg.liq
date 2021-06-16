#!./liquidsoap
s = input.ffmpeg(format="lavfi", "sine=frequency=440")
output(s)
