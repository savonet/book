#!./liquidsoap
# header
radio = playlist("~/Music")
output.icecast(fallible=true, format="audio/mpeg", mount="radio",
               %ffmpeg(format="mp3", %audio.copy), radio)
# footer
output.file(fallible=true, %ffmpeg(format="mp3", %audio.copy), "radio.mp3", radio)
