#!./liquidsoap
# Test surround sound
audio.channels := 6
s = single("test.mp3")
output(s)
