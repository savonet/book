#!./liquidsoap
radio = playlist("~/Music")
output.icecast(fallible=true, format="audio/mpeg", mount="radio",
               %ffmpeg(format="mp3", %audio.copy), radio)
radio = ffmpeg.decode.audio(radio)
# From there the radio source is decoded
output.icecast(fallible=true, format="audio/mpeg", mount="radio-opus",
               %opus, radio)
output(radio)