#!/usr/bin/env liquidsoap
s = playlist("~/Music")
def f(m)
  [
    ("title",   "#{m['title']} (#{m['year']})"),
    ("comment", "Encoded by Liquidsoap!")
  ]
end
s = map_metadata(f, s)
s.on_metadata(fun (m) -> print(json_of(m))); output(s)
