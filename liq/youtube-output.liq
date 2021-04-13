#!./liquidsoap
log.level.set(5)
radio = playlist("~/Music")
video = single("image.jpg")
radio = mux_video(video=video, radio)
ykey  = string.trim(file.contents("youtube-key"))
url   = "rtmp://a.rtmp.youtube.com/live2/#{ykey}"
enc   = %ffmpeg(format="flv",
          %video(codec="libx264", pixel_format="yuv420p",
                 b="300k", preset="superfast", r=25, g=50),
          %audio(codec="libmp3lame", samplerate=44100, b="160k"))
output.url(fallible=true, url=url, enc, radio)
