#!./liquidsoap
s1 = single("test.mp4")
s2 = single("test.mp4")
s = mux_audio(audio=drop_video(s1), drop_audio(s2))
output.audio_video(s)