#!./liquidsoap
s = input.hls("https://stream.radiofrance.fr/fip/fip.m3u8")
output(buffer(s))
