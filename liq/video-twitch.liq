#!./liquidsoap
s = single("video.mkv")
# header
key = string.trim(file.contents("twitch-key"))
rtmp_url = "rtmp://cdg.contribute.live-video.net/app/#{key}"
enc = %ffmpeg(format="flv",
              %audio(codec="libmp3lame", samplerate=44100, b="128k"),
              %video(codec="libx264", width=854, height=480,
                     b="800k", g=50, preset="veryfast"))
output.url(fallible=true, url=rtmp_url, enc, s)
# footer
thread.run(every=1., {print(time.up())})
