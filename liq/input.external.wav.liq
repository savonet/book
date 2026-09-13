#!./liquidsoap
# header
cmd = "ffmpeg -f lavfi -i sine=frequency=440 -ac 2 -f wav -"
s   = input.external.wav(cmd)
# footer
output(s)
