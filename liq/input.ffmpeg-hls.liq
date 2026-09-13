#!./liquidsoap
# header
s = input.ffmpeg("https://stream.radiofrance.fr/fip/fip.m3u8")
# footer
output(buffer(s))
