#!/usr/bin/env liquidsoap
s = playlist("~/Music")
def update_metadata(m)
  [
    ("title",   "#{m['title']} (#{m['year']})"),
    ("comment", "Encoded by Liquidsoap!")
  ]
end
s = map_metadata(update_metadata, s)
s.on_metadata(fun (m) -> print(json.stringify(m))); output(s)
