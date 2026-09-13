#!./liquidsoap
s = single("jo.mp4")
# header
s = video.add_text(size=30, "Hello world!", s)
# footer
output.audio_video(s)
