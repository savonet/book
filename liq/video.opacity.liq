#!./liquidsoap
s1 = single("jo.mp4")
s2 = single("webcam.mkv")
# header
s = add([s1, video.opacity(.75, s2)])
# footer
output.audio_video(s)
