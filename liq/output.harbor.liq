#!./liquidsoap
radio = mksafe(playlist("~/Music"))
output.harbor(%mp3, mount="my-radio.mp3", radio)
