#!/usr/bin/env liquidsoap
set("server.telnet", true)
s = playlist("~/Music")
s = insert_metadata(s)
def cmd(t)
  s.insert_metadata([("title", t)])
  "Title set!"
end
server.register("set_title", cmd)
s.on_metadata(fun(m) -> print(json_of(m))); output(s)
