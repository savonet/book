#!/usr/bin/env liquidsoap
mic = sine()
bed = playlist("~/Music")
radio = add([mic, amplify(1./3., bed)])
out(radio)
