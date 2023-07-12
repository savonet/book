#!./liquidsoap
s = playlist("~/Music")
s = source.mux.video(video=blank(), s)
s = rms(s)
rms = s.rms
s = bpm(s)
bpm = s.bpm
s = video.add_text.native(color=0x9999ff, speed=0, x=50, y=50, size=50,
                          {"Volume: #{rms()}\nBPM: #{bpm()}"}, s)
output.audio_video(s)
