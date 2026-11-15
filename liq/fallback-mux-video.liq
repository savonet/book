#!./liquidsoap
# header
live = single("video.mp4")
music = source.mux.video(video=image("cover.png"), playlist("~/Music"))
s = fallback([live, music])
# footer
output.file(
  %ffmpeg(%audio(codec="aac"), %video(codec="libx264")),
  "archive.mp4",
  s
)
