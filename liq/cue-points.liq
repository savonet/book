#!./liquidsoap
# header
s = playlist(prefix="annotate:liq_cue_in=3.,liq_cue_out=9.5:", "~/Music")
# footer
output(s)
