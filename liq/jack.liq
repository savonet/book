#!./liquidsoap
radio = mksafe(playlist("~/Music"))
output.jack(id="my-radio-out", radio)
radio2 = input.jack(id="my-radio-in")
output.icecast(mount="radio", %mp3, radio2)
output.alsa(fallible=true, buffer.adaptative(radio2))
