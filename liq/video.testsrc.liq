#!./liquidsoap
log.level.set(5)
s = video.testsrc.ffmpeg()
clock(sync="cpu", output.graphics(fallible=true, s))
# output.file(%avi, "/tmp/out.avi", mksafe(mux_audio(audio=blank(), s)))