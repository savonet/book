#!./liquidsoap
radio = mksafe(playlist("~/Music"))
# header
output.harbor(%mp3, mount="my-radio.mp3", radio)
