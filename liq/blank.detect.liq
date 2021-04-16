#!./liquidsoap
radio = playlist("~/Music")
radio = blank.detect(
  {process.run("send-text-msg 'The radio is streaming blank!'")},
  radio)
output(radio)
