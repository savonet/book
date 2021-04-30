#!./liquidsoap
s = single("video.mkv")
key = string.trim(file.contents("facebook-key"))
url = "rtmps://live-api-s.facebook.com:443/rtmp/#{key}"
enc = %ffmpeg(format="flv",
              %audio(codec="aac", samplerate=44100, b="96k"),
              %video(codec="libx264", width=854, height=480,
                     b="800k", g=50, preset="veryfast"))
output.url(fallible=true, url=url, enc, s)
thread.run(every=1., {print(clock.status.seconds())})