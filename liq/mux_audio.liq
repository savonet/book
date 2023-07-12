#!./liquidsoap
a = single("test.mp3") v = single("test.mp4")
s = source.mux.audio(audio=a, v)
output.audio_video(s)
