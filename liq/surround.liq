#!./liquidsoap
# Test surround sound
settings.frame.audio.channels := 6
s = single("test.mp3")
output(s)
