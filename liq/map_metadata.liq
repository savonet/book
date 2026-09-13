#!./liquidsoap
s = playlist("~/Music")
# header
def update_metadata(m)
  [
    ("title",   "#{m['title']} (#{m['year']})"),
    ("comment", "Encoded by Liquidsoap!")
  ]
end
s = metadata.map(update_metadata, s)
# footer
s.on_metadata(synchronous=true, fun (m) -> print(metadata.json.stringify(m))); output(s)
