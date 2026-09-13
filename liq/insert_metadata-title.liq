#!/usr/bin/env liquidsoap
server.telnet()
s = playlist("~/Music")
# header
def cmd(t)
  s.insert_metadata([("title", t)])
  "Title set to #{t}."
end
server.register("set_title", cmd)
# footer
s.on_metadata(synchronous=true, fun(m) -> print(metadata.json.stringify(m))); output(s)
