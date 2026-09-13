#!./liquidsoap
s = single("jo.mp4")
# header
s = video.frei0r.distort0r(s)
# footer
output.audio_video(s)
