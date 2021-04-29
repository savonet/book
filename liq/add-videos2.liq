#!./liquidsoap
s = playlist("videos")
s = video.add_image(x=10, y=10, width=50, height=50, file="test.png", s)
output.audio_video(s)
