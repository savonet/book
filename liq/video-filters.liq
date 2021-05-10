#!./liquidsoap
s = mux_audio(audio=blank(), single("photo.jpg"))
s = video.sepia(s)
# s = video.invert(s)
# s = video.opacity(0.5, s)
s = video.still_frame(s)
output.audio_video(s)
thread.run(delay=1., {s.save("/tmp/out.bmp")})
# thread.run(delay=2., shutdown)
