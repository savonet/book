#!./liquidsoap
# header
ice_server = icecast.server({source_password = "hackme"})
radio = mksafe(playlist("~/Music"))
radio =
  ffmpeg.encode.audio(
    %ffmpeg(%audio(codec = "libmp3lame", sample_format = "fltp")),
    radio
  )

ice_server.attach_source(
  format=%ffmpeg(format = "mp3", %audio.copy),
  headers=[("ice-name", "My radio")],
  "/autodj.mp3",
  radio
)
