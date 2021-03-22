#!/usr/bin/env liquidsoap
mic   = sine()
bed   = playlist("~/Music")
radio = add([amplify(2., mic), amplify(1., bed)])
output(radio)
