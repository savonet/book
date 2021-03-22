#!/usr/bin/env liquidsoap
mic   = sine()
bed   = playlist("~/Music")
radio = add(weights=[2., 1.], [mic, bed])
output(radio)
