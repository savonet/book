#!./liquidsoap
# header
mic   = input.alsa()
radio = amplify(1.2, mic)
# footer
output(radio)
