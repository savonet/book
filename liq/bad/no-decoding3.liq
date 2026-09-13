#!./liquidsoap
radio = playlist("~/Music")
# header
radio = amplify(0.8, radio)
# footer
output.icecast(fallible=true, format="audio/mpeg", mount="radio",
               %ffmpeg(format="mp3", %audio.copy), radio)
output.file(fallible=true, %ffmpeg(format="mp3", %audio.copy), "radio.mp3", radio)
