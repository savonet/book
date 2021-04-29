#!./liquidsoap
s = playlist("videos.playlist")
s = video.still_frame(s)
thread.run(every=2., {s.save("/tmp/out.bmp")})
output.audio_video(s)
