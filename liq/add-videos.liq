#!./liquidsoap
s    = playlist("videos")
logo = image("annotate:x=10,y=10,width=50,height=50:test.png")
s    = add([s, logo])
output.audio_video(s)
