radio = blank()
radio = on_metadata(fun (m) -> print(m["title"]), radio)
out(radio)