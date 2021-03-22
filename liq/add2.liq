#!/usr/bin/env liquidsoap
mic   = sine()
bed   = playlist("~/Music")
radio = add(normalize=false, [mic, bed])
output(radio)
