#!./liquidsoap
radio = mksafe(playlist("~/Music")) file.mkdir("/tmp/hls")
output.harbor.hls(port=8000, path="radio/", [("mp3", %mp3)], radio)