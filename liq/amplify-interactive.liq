#!./liquidsoap
s = playlist("~/Music") set("server.telnet", true) interactive.harbor()
a = interactive.float("main_volume", 1.)
s = amplify(a, s)
interactive.persistent("/tmp/amp.params") output(s)
