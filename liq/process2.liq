#!/usr/bin/env liquidsoap
s = single("process:wav,echo 'Hello world!' | text2wave > $(output)")
s = audio_to_stereo(s)
output(s)
