#!./liquidsoap
radio = mksafe(playlist("~/Music"))
file.mkdir("hls")
# header
radio = ffmpeg.encode.audio(%ffmpeg(%audio(codec="libmp3lame")), radio)
# From there the radio source is in mp3 format
output.icecast(%ffmpeg(format="mp3", %audio.copy), mount="radio", radio)
output.file.hls("hls",
                [("mp3", %ffmpeg(format="mp3", %audio.copy))], radio)
output.file(%ffmpeg(format="mp3", %audio.copy),
            "radio.mp3", radio)
