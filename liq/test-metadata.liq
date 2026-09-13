#!./liquidsoap
server.telnet()
# header
s = playlist(id="s", "~/Music")
def handle_metadata(m)
  print("Metadata:\n#{metadata.json.stringify(m)}")
end
s.on_metadata(synchronous=true, handle_metadata)
thread.run(every=10., {s.skip()})
output(s)
