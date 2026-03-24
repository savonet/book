#!./liquidsoap
s = playlist("~/Music")
s = source.mux.video(video=blank(), s)
s = rms(s)
s_rms = s.rms
s = bpm(s)
s_bpm = s.bpm
s = video.add_text.native(color=0x9999ff, speed=0, x=50, y=50, size=50,
                          {"Volume: #{s_rms()}\nBPM: #{s_bpm()}"}, s)
output.audio_video(s)
