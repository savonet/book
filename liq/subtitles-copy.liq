#!./liquidsoap
s = input.ffmpeg(self_sync=true, "movie.mkv")
let {audio, video, subtitles} = source.tracks(s)
output.file(
  %ffmpeg(format="matroska", %audio.copy, %video.copy, %subtitle.copy),
  "output.mkv",
  source({audio = audio, video = video, subtitle = subtitles}))
