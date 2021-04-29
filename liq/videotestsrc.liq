#!./liquidsoap
log.level.set(5)
s = (input.ffmpeg(buffer=1., format="lavfi", "rgbtestsrc=size=1280x720:rate=25"):source(audio=none))
output.video(s)
# output.file(fallible=true, %avi, "/tmp/out.avi", mux_audio(audio=blank(), s))
