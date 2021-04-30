#!./liquidsoap
s = single("test.avi")
# output.file(
# %ffmpeg(format="mp4", %audio(codec="libmp3lame", q=4), %video(codec="libx264", preset="normal", crf=18))
# %ffmpeg(format="mp4", %audio(codec="libmp3lame", q=4), %video(codec="libx264", preset="medium", crf=18))
# , "/tmp/out", s)
# output.audio_video(s)
output.graphics(fallible=true, s)