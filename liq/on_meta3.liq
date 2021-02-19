radio = blank()
handle_metadata = fun (m) -> begin
  print(m["artist"])
  print(m["title"])
end
radio.on_metadata(handle_metadata)
output(radio)
