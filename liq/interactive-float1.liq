mic = sine()
volume = interactive.float("volume", 1.)
radio = amplify(volume, mic)
output(radio)
