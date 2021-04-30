#!./liquidsoap
s = single("jo.mp4")
s = video.frei0r.distort0r(s)
output.audio_video(s)
