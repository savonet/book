#!./liquidsoap
radio = playlist("~/Music")
handle_metadata = fun (m) -> begin
  print(m["artist"])
  print(m["title"])
end
source.on_metadata(radio, handle_metadata)
output(radio)
