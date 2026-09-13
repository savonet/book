#!./liquidsoap
radio = playlist("~/Music")
# header
def handle_metadata(m) =
  print(m["title"])
end
radio.on_metadata(synchronous=true, handle_metadata)
# footer
output(radio)
