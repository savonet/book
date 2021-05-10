#!./liquidsoap
s = mux_audio(audio=blank(), input.v4l2())
output.audio_video(s)
