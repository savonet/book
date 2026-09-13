#!./liquidsoap
s = single("test.mp4")
# header
s = video.fade.in(transition="disc", s)
# footer
output.audio_video(s)
