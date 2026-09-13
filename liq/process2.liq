#!./liquidsoap
# header
s = single("process:wav,echo 'Hello world!' | text2wave > $(output)")
# footer
s = stereo(s)
output(s)
