mic    = sine()
# header
volume = interactive.float("volume", 1.)
radio  = amplify({lin_of_dB(volume())}, mic)
# footer
output(radio)
