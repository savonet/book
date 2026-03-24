#!./liquidsoap
s = single("video.mkv")
let {audio} = source.tracks(s)
encoded_audio = track.ffmpeg.encode.audio(%ffmpeg(%audio(codec="aac")), audio)
encoded = source({
  audio       = encoded_audio,
  metadata    = track.metadata(encoded_audio),
  track_marks = track.track_marks(encoded_audio)
})
