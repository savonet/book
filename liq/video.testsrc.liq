#!./liquidsoap
log.level.set(5)
s = video.testsrc.ffmpeg()
output.video(s)
