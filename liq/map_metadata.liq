#!./liquidsoap
s = playlist("~/Music")
def update_metadata(m)
  [
    ("title",   "#{m['title']} (#{m['year']})"),
    ("comment", "Encoded by Liquidsoap!")
  ]
end
s = metadata.map(update_metadata, s)
s.on_metadata(fun (m) -> print(metadata.json.stringify(m))); output(s)
