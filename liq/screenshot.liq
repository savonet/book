#!./liquidsoap
s = single("video.mp4")
s = video.still_frame(s)
thread.run(every=10., {s.save("/tmp/shot#{time()}.bmp")})
output.audio_video(s)
