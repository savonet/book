#!/usr/bin/env liquidsoap
mic = sine()
bed = playlist("~/Music")
radio = add([mic, bed])
out(radio)
