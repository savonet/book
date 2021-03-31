#!./liquidsoap
s = normalize(playlist("~/Music")) s0 = s interactive.harbor()
# s = lv2.calf_multiband_compressor(s)
# s = ladspa.lsp_mb_compressor_stereo(s)
w = interactive.float("wet", min=0., max=1. ,1.)
s = dry_wet(w, s0, s)
output(s)
