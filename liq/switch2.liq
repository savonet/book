#!/usr/bin/env liquidsoap
set("server.telnet", true)
radio1 = saw()
radio2 = sine()
# p = {true}
# p = {file.contents("select-radio") == "1"}
p = interactive.bool("radio1", false)
radio = switch(track_sensitive=false, [(p, radio1), ({true}, radio2)])
out(radio)