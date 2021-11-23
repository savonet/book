#!/usr/bin/env liquidsoap
s = playlist("~/Music")
s = insert_metadata(s)
thread.run(every=60., {
  s.insert_metadata([("artist", "Liquidsoap"),("title", "Liquidsoap")])
  })
s.on_metadata(fun(m) -> print(metadata.json.stringify(m))); output(s)
