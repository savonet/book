#!./liquidsoap
s = single("video.mkv")
let {audio, video, metadata, track_marks} = source.tracks(s)
