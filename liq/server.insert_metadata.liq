#!/usr/bin/env liquidsoap
set("server.telnet", true)
s = playlist("~/Music")
s = server.insert_metadata(id="src", s)
s.on_metadata(fun(m) -> print(metadata.json.stringify(m))); output(s)
