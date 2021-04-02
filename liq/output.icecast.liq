#!./liquidsoap
radio = mksafe(playlist("~/Music"))
output.icecast(%mp3, host="localhost", port=8000,
               password="hackme", mount="my-radio.mp3", radio)
