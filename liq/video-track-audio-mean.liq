#!./liquidsoap
s = single("video.mkv")
let {audio} = source.tracks(s)
mono = track.audio.mean(audio)
