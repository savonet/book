#!./liquidsoap
# This script typechecks but fails at startup with an Error 7: `input.srt`
# controls its own latency, and `stretch` needs a source it can accelerate.
# header
s = mksafe(input.srt())
output(stretch(ratio=2., s))
