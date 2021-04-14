#!./liquidsoap
radio = mksafe(playlist("~/Music")) file.mkdir("hls")
output.icecast(%mp3, mount="radio", radio)
output.file.hls("hls", [("mp3", %mp3)], radio)
output.file(%mp3, "radio.mp3", radio)
