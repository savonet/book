#!/usr/bin/env liquidsoap
s = sine()
# header
%ifencoder %mp3
output.file(%mp3, "out.mp3", s)
%endif
%ifnencoder %mp3
output.file(%wav, "out.wav", s)
%endif
