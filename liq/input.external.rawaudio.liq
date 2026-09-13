#!./liquidsoap
# header
cmd = "ffmpeg -f lavfi -i sine=frequency=440 -ac 2 -f s16le -"
s   = input.external.rawaudio(cmd)
# footer
output(s)
