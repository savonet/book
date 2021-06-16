#!./liquidsoap
s = playlist("videos.playlist")
w = mux_audio(audio=blank(), input.v4l2())
w = video.scale(x=10, y=10, scale=0.1, w)
s = add([s, w])
output.audio_video(s)
