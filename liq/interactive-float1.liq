mic    = sine()
# header
volume = interactive.float("volume", 1.)
radio  = amplify(volume, mic)
# footer
output(radio)
