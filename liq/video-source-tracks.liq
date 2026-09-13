#!./liquidsoap
s = single("video.mkv")
# header
let {audio, video, metadata, track_marks} = source.tracks(s)
