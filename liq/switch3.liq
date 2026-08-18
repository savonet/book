#!/usr/bin/env liquidsoap
radio1 = saw()
radio2 = sine()
p = {file.contents("select-radio") == "1"}
server.telnet()
p = interactive.bool("r1", false)
radio = switch([(p, radio1.{track_sensitive = false}), ({true}, radio2)])
output(radio)
