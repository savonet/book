#!./liquidsoap
radio = mksafe(playlist("~/Music")) file.mkdir("hls")
radio = ffmpeg.encode.audio(%ffmpeg(%audio(codec="libmp3lame")), radio)
# From there the radio source is in mp3 format
output.icecast(fallible=true, format="audio/mpeg",
               %ffmpeg(format="mp3", %audio.copy), mount="radio", radio)
output.file.hls(fallible=true, "hls",
                [("mp3", %ffmpeg(format="mp3", %audio.copy))], radio)
output.file(fallible=true, %ffmpeg(format="mp3", %audio.copy),
            "radio.mp3", radio)
