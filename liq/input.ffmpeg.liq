#!./liquidsoap
s = input.ffmpeg(format="lavfi", "sine=frequency=440")
output(buffer(s))
