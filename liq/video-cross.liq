#!./liquidsoap
log.level.set(5)
s = playlist("videos.playlist")
s = video.fade.out(duration=1., s)
s = video.fade.in (duration=1., s)
s = cross(duration=1.5, fun (a,b) -> add([a.source, b.source]), s)
output.audio_video(s)
