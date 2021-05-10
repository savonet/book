#!./liquidsoap
log.level.set(5)
output.video(input.v4l2(buffer=1.))
