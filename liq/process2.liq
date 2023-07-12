#!./liquidsoap
s = single("process:wav,echo 'Hello world!' | text2wave > $(output)")
s = stereo(s)
output(s)
