#!./liquidsoap
s = single("video.mkv")
# header
let {audio} = source.tracks(s)
mono = track.audio.mean(audio)
