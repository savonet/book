#!./liquidsoap
s = single("video.mkv")
# header
let {track_marks=_, ...tracks} = source.tracks(s)
s2 = source(tracks)
