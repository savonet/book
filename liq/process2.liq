#!/usr/bin/env liquidsoap
s = audio_to_stereo(single("process:wav,echo 'Hello world!' | \
                            text2wave > $(output)"))
out(s)