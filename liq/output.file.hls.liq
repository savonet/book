#!./liquidsoap
radio = mksafe(playlist("~/Music")) file.mkdir("/tmp/hls")
output.file.hls("/tmp/hls",
  [("mp3-low", %mp3(bitrate=96)), ("mp3-hi", %mp3(bitrate=160))],
  radio)