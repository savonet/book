#!./liquidsoap
a = single("test.mp3")
v = single("test.mp4")
# header
s = source.mux.audio(audio=a, v)
# footer
output.audio_video(s)
