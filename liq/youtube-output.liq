#!./liquidsoap
log.level := 5
# header
radio = playlist("~/Music")
v = single("image.jpg")
radio = source.mux.video(video=v, radio)
ykey  = string.trim(file.contents("youtube-key"))
rtmp_url = "rtmp://a.rtmp.youtube.com/live2/#{ykey}"
enc   = %ffmpeg(format="flv",
          %video(codec="libx264", pixel_format="yuv420p",
                 b="300k", preset="superfast", r=25, g=50),
          %audio(codec="libmp3lame", samplerate=44100, b="160k"))
output.url(fallible=true, url=rtmp_url, enc, radio)
