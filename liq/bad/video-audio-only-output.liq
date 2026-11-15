#!./liquidsoap
# header
s = single("video.mp4")
output.file(
  %ffmpeg(%audio(codec="aac"), %video(codec="libx264")),
  "archive.mp4",
  s
)
output.icecast(%mp3, mount="radio", s)
