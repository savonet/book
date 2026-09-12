#!./liquidsoap
here = path.dirname(liquidsoap.script.path ?? ".")
music = playlist("#{here}/music")
output(mksafe(music))
