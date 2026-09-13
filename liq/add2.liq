#!/usr/bin/env liquidsoap
mic   = sine()
bed   = playlist("~/Music")
# header
radio = add(normalize=false, [mic, bed])
# footer
output(radio)
