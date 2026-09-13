#!./liquidsoap
radio  = sine()
# header
volume = metadata.getter.float(1., "liq_amplify", radio)
radio  = amplify(volume, radio)
# footer
output.dummy(radio)
