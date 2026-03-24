#!./liquidsoap
radio = playlist("~/Music")
radio = blank.detect(radio)
radio.on_blank(synchronous=false,
  {process.run("send-text-msg 'The radio is streaming blank!'")})
output(radio)
