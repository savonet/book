#!./liquidsoap
# header
radio = playlist("~/Music")
output.icecast(fallible=true, mount="radio", %mp3, radio)
# footer
output(radio)
