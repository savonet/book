#!./liquidsoap
log.level := 5
# s = input.v4l2()
# s = mux_audio(audio=input(), s)
s = single("video.mkv")
ykey  = string.trim(file.contents("youtube-key"))
url   = "rtmp://a.rtmp.youtube.com/live2/#{ykey}"
# enc   = %ffmpeg(format="mp4",
          # %video(codec="libx264", b="300k", preset="superfast"),
          # %audio(codec="libmp3lame", samplerate=44100, q=5))
enc = %ffmpeg(format="webm",
        %audio(codec="libopus", samplerate=48000, b="128k"),
        %video(codec="libvpx-vp9", width=854, height=480,
               quality="realtime", speed=7, b="500k"))
output.url(fallible=true, url=url, enc, s)
