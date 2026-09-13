#!./liquidsoap
# This script typechecks but fails at startup with an Error 11: the same
# source `s` cannot be both inside the child clock of `stretch` and in the
# clock of `add`.
# header
s = mksafe(playlist("~/Music"))
o = add([stretch(ratio=2., s), s])
# footer
output(o)
