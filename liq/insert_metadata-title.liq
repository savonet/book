#!/usr/bin/env liquidsoap
set("server.telnet", true)
s = playlist("~/Music")
def cmd(t)
  s.insert_metadata([("title", t)])
  "Title set to #{t}."
end
server.register("set_title", cmd)
s.on_metadata(synchronous=true, fun(m) -> print(metadata.json.stringify(m))); output(s)
