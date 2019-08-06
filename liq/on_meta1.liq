radio = blank()
def handle_metadata(m) =
  print(m["title"])
end
radio = on_metadata(handle_metadata, radio)
out(radio)