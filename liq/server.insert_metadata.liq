#!/usr/bin/env liquidsoap
set("server.telnet", true)
s = playlist("~/Music")
s.register_command(description="Insert metadata.",
                   usage="insert key1=val1,key2=val2,...",
  "insert", fun(args) ->
    begin
      s.insert_metadata(list.map(
        fun(p) -> (fst(p), snd(p)),
        list.filter_map(
          fun(kv) -> begin
            let [k, v, ...] = string.split(separator="=", kv)
            (k, v)
          end,
          string.split(separator=",", args))))
      "Done."
    end)
s.on_metadata(synchronous=true, fun(m) -> print(metadata.json.stringify(m))); output(s)
