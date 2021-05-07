#!./liquidsoap
video.frame.width.set(640) video.frame.height.set(360) %include "ffmpeg-effect3.liq"
def myfilter'(s)
  s = ffmpeg.raw.encode.audio_video(%ffmpeg(%audio.raw, %video.raw), s)
  s = myfilter(s)
  ffmpeg.raw.decode.audio_video(s)
end
s = single("lf.mp4")
s = myfilter'(s)
output.audio_video(s)
