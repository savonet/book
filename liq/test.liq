#!./liquidsoap
s = single("video.mkv")
s = cross(fun (_,_,_,_,a,b) -> add([a,b]), s)
output.audio_video(s)
