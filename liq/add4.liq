#!/usr/bin/env liquidsoap
mic   = sine()
bed   = playlist("~/Music")
# header
radio = add([amplify(2., mic), amplify(1., bed)])
# footer
output(radio)
