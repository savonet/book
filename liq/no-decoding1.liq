#!./liquidsoap
radio = playlist("~/Music")
output.icecast(fallible=true, mount="radio", %mp3, radio)
output(radio)