#!./liquidsoap
radio = playlist("~/Music")
radio.on_metadata(synchronous=true, fun (m) -> print(m["title"]))
output(radio)
