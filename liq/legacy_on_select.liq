#!./liquidsoap
s = playlist("~/Music")
# header
s = s.{on_select = source.composition.legacy_on_select}
# footer
output(s)
