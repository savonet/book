#!./liquidsoap
s = input.external.wav("ffmpeg -f lavfi \
    -i 'sine=frequency=440:duration=5' -ac 2 -f wav -")
out(s)
