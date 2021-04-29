#!./liquidsoap
s = single("jo.mp4")
s = video.add_text.sdl(size=30, "Hello world!", s)
output.audio_video(s)
