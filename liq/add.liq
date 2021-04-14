#!./liquidsoap
mic = input.harbor("mic")
bed   = playlist("~/Music")
radio = add([mic, bed])
output(radio)
