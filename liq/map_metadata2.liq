#!/usr/bin/env liquidsoap
s = playlist("~/Music")
def update_metadata(m) =
  title = path.remove_extension(path.basename(m["filename"]))
  [("title", title)]
end
s = map_metadata(update_metadata, s)
s.on_metadata(fun (m) -> print("Title: #{m['title']}")); thread.run(every=2., s.skip); output(s)
