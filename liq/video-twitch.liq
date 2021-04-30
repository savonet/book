#!./liquidsoap
s = single("video.mkv")
key = string.trim(file.contents("twitch-key"))
url = "rtmp://cdg.contribute.live-video.net/app/#{key}"
enc = %ffmpeg(format="flv",
              %audio(codec="libmp3lame", samplerate=44100, b="128k"),
              %video(codec="libx264", width=854, height=480,
                     b="800k", g=50, preset="veryfast"))
output.url(fallible=true, url=url, enc, s)
thread.run(every=1., {print(clock.status.seconds())})