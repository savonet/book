#!./liquidsoap
s = mksafe(playlist("~/Music"))
o = add([stretch(ratio=2., s), s])
output(o)