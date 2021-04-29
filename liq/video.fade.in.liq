#!./liquidsoap
s = single("test.mp4")
s = video.fade.in(transition="disc", s)
output.audio_video(s)