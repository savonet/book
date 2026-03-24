#!./liquidsoap
s = single("video.mkv")
let {track_marks=_, ...tracks} = source.tracks(s)
s2 = source(tracks)
