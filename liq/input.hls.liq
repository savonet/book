#!./liquidsoap
# header
s = input.hls("https://stream.radiofrance.fr/fip/fip.m3u8")
# footer
output(s)
