#!./liquidsoap
s = single("video.mkv")
let {audio, video, metadata, track_marks} = source.tracks(s)
s2 = source({audio=audio, video=video, metadata=metadata,
             track_marks=track_marks})
