#!./liquidsoap -i
log.level.set(5)
s = single("test.mp3")
output((s:source(audio=pcm(mono))))
