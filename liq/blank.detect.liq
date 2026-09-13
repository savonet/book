#!./liquidsoap
radio = playlist("~/Music")
# header
radio = blank.detect(radio)
radio.on_blank(synchronous=false,
  {process.run("send-text-msg 'The radio is streaming blank!'")})
# footer
output(radio)
