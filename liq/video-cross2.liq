#!./liquidsoap
log.level.set(5)
s = playlist("videos.playlist")
s = video.fade.in (duration=1., transition="slide_right", s)
s = cross(duration=1., fun (a,b) -> add([a.source, b.source]), s)
output.audio_video(s)
