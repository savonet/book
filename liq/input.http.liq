#!/usr/bin/env liquidsoap
s = input.http("http://direct.fipradio.fr/live/fip-midfi.mp3")
output(s)
