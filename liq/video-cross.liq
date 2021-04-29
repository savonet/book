#!./liquidsoap
log.level.set(5)
a = merge_tracks(playlist("~/Music"))
v = (playlist(mode="normal", prefix="annotate:duration=5:", "image.playlist"):source(audio=none))
s = mux_video(video=v, a)
s = video.fade.out(s)
s = cross(fun (_,_,_,_,a,b) -> add([a,b]), s)
output.audio_video(s)
