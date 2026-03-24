#!./liquidsoap
s = input.ffmpeg("movie.mkv")
output.file(
  %ffmpeg(format="matroska", %video(codec="libx264"),
          %subtitle(codec="subrip")),
  "output.mkv", s)
