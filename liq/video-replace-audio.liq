#!./liquidsoap
v = single("video.mkv")
music = playlist("~/Music")
s = source(source.tracks(v).{audio = source.tracks(music).audio})
