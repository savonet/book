#!./liquidsoap
s = playlist("~/Music")
s = s.{on_select = source.composition.legacy_on_select}
output(s)
