#!./liquidsoap
s = normalize(playlist("~/Music")) interactive.harbor()
settings.osc.port.set(9000)
a = interactive.float(osc="/volume", "main_volume", 1.)
s = amplify(a, s)
output(s)
