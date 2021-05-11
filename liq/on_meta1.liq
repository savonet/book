#!./liquidsoap
radio = playlist("~/Music")
def handle_metadata(m) =
  print(m["title"])
end
source.on_metadata(radio, handle_metadata)
output(radio)
