#!./liquidsoap
radio = mksafe(playlist("~/Music")) file.mkdir("hls")
enc   = %ffmpeg(format="mp3", %audio(codec="libmp3lame"))
output.icecast(enc, mount="radio", radio)
output.file.hls("hls", [("mp3", enc)], radio)
output.file(enc, "radio.mp3", radio)
