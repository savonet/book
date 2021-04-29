#!./liquidsoap
s = playlist("videos")
x = {int(10.+10.*cos(6.*time()))}
y = {int(10.+10.*sin(6.*time()))}
s = video.add_image(x=x, y=y, width=50, height=50, file="test.png", s)
output.audio_video(s)
