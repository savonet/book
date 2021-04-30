#!./liquidsoap
s = single("video.mkv")
key = string.trim(file.contents("youtube-key"))
url = "rtmp://a.rtmp.youtube.com/live2/#{key}"
enc = %ffmpeg(format="flv",
              %audio(codec="libmp3lame", samplerate=44100, q=5),
              %video(codec="libx264", width=854, height=480,
                     b="800k", g=50, preset="veryfast"))
output.url(fallible=true, url=url, enc, s)
thread.run(every=1., {print(clock.status.seconds())})
