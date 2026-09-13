#!./liquidsoap
# This script typechecks but fails at startup: an mp3 file has no video
# track, so no decoder can produce what `output.video` asks for.
# header
log.level := 5
output.video(single("test.mp3"))
