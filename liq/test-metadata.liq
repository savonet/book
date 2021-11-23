#!./liquidsoap
set("server.telnet", true)
s = playlist(id="s", "~/Music")
def handle_metadata(m)
  print("Metadata:\n#{json.stringify(m)}")
end
s.on_metadata(handle_metadata)
thread.run(every=10., {s.skip()})
output(s)
