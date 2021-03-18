#!./liquidsoap
radio  = sine()
volume = metadata.getter.float(1., "liq_amplify", radio)
radio  = amplify(volume, radio)
output.dummy(radio)