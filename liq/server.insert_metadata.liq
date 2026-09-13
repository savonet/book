#!/usr/bin/env liquidsoap
server.telnet()
# header
s = playlist(id="src", "~/Music")
def insert(args)
  let (meta, _) = string.annotate.parse("#{args}:")
  s.insert_metadata(meta)
  "Done."
end
s.register_command(description="Insert a metadata chunk.",
                   usage="insert key1=\"val1\",key2=\"val2\",...",
                   "insert", insert)
# footer
output(s)
