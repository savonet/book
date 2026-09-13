#!./liquidsoap
# header
here = path.dirname(liquidsoap.script.path ?? ".")
music = playlist("#{here}/music")
# footer
output(mksafe(music))
