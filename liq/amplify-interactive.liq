#!./liquidsoap
s = playlist("~/Music")
server.telnet()
interactive.harbor()
# header
a = interactive.float("main_volume", 1.)
s = amplify(a, s)
# footer
interactive.persistent("/tmp/amp.params")
output(s)
