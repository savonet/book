#!/usr/bin/env liquidsoap
radio1 = saw()
radio2 = sine()
p = {file.contents("select-radio") == "1"}
set("server.telnet", true)
p = interactive.bool("r1", false)
radio = switch(track_sensitive=false, [(p, radio1), ({true}, radio2)])
output(radio)
