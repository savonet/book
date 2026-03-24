#!./liquidsoap
s = once(single("movie.mkv"))
let {audio, video, subtitles} = source.tracks(s)
s = source({audio = audio, video = track.video.add([video, subtitles])})
output.file(
  fallible=true,
  %ffmpeg(%audio(codec="aac"), %video(codec="libx264")),
  "output.mp4", s)
