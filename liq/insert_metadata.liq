#!/usr/bin/env liquidsoap
s = playlist("~/Music")
thread.run(every=60., {
  s.insert_metadata([("artist", "Liquidsoap"),("title", "Liquidsoap")])
  })
s.on_metadata(synchronous=true, fun(m) -> print(metadata.json.stringify(m))); output(s)
