#!./liquidsoap
s = playlist("~/Music")
# header
def update_metadata(m) =
  title = path.remove_extension(path.basename(m["filename"]))
  [("title", title)]
end
s = metadata.map(update_metadata, s)
# footer
s.on_metadata(synchronous=true, fun (m) -> print("Title: #{m['title']}")); thread.run(every=2., s.skip); output(s)
