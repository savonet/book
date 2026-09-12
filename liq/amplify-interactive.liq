#!./liquidsoap
s = playlist("~/Music")
server.telnet()
interactive.harbor()
a = interactive.float("main_volume", 1.)
s = amplify(a, s)
interactive.persistent("/tmp/amp.params")
output(s)
