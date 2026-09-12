#!/usr/bin/env liquidsoap
# Rejected at startup with Error 17: the ALSA input and the output are two
# synchronization sources in the same clock.
output(input.alsa())
