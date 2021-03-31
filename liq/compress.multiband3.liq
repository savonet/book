#!./liquidsoap
s = normalize(playlist("~/Music"))
interactive.harbor()
s = compress.multiband.interactive(bands=3, s)
output(s)
interactive.persistent("comp.params")
