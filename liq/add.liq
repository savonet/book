#!./liquidsoap
# header-a
mic = input.harbor("mic")
# footer-a
bed   = playlist("~/Music")
# header-b
radio = add([mic, bed])
# footer-b
output(radio)
