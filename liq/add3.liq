#!/usr/bin/env liquidsoap
mic   = sine()
bed   = playlist("~/Music")
# header
radio = add(weights=[2., 1.], [mic, bed])
# footer
output(radio)
