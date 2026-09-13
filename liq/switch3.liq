#!/usr/bin/env liquidsoap
radio1 = saw()
radio2 = sine()
# header-a
p = {file.contents("select-radio") == "1"}
# footer-a
# header-b
server.telnet()
p = interactive.bool("r1", false)
# footer-b
# header-c
radio = switch([(p, radio1.{track_sensitive = false}), ({true}, radio2)])
# footer-c
output(radio)
