#!./liquidsoap
radio = playlist("~/Music")
output.icecast(fallible=true, format="audio/mpeg", mount="radio",
               %ffmpeg(format="mp3", %audio.copy), radio)
output.file(fallible=true, %ffmpeg(format="mp3", %audio.copy), "radio.mp3", radio)