#!/usr/bin/env liquidsoap
s = input.ffmpeg("https://stream.radiofrance.fr/fip/fip.m3u8")
output(s)
