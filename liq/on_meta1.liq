#!./liquidsoap
radio = playlist("~/Music")
def handle_metadata(m) =
  print(m["title"])
end
radio.on_metadata(synchronous=true, handle_metadata)
output(radio)
