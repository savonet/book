#!./liquidsoap
s1 = single("jo.mp4")
s2 = single("webcam.mkv")
s = add([s1, s2])
output.audio_video(s)
