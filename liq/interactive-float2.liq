mic = sine()
volume = interactive.float("volume", 1.)
radio = amplify({lin_of_dB(volume())}, mic)
out(radio)
