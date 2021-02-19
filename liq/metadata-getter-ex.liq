radio  = sine()
volume = metadata.float_getter(1., "liq_amplify", radio)
radio  = amplify(volume, radio)
output.dummy(radio)