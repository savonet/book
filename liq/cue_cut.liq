#!./liquidsoap
log.level.set(5); set("decoder.priorities.mad",20) # See bug 1546
s = playlist(prefix="annotate:liq_cue_in=3,liq_cue_out=9.5:", "~/Music")
s = cue_cut(s)
output(s)
