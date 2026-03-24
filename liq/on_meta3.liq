#!./liquidsoap
radio = playlist("~/Music")
handle_metadata = fun (m) -> begin
  print(m["artist"])
  print(m["title"])
end
radio.on_metadata(synchronous=true, handle_metadata)
output(radio)
