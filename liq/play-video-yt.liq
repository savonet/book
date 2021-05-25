#!./liquidsoap
log.level.set(4)
server.harbor()
s = single(timeout=600.,
  "youtube-dl:https://www.youtube.com/watch?v=dQw4w9WgXcQ")
output.audio_video(s)
