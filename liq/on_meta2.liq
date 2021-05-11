#!./liquidsoap
radio = playlist("~/Music")
source.on_metadata(radio, fun (m) -> print(m["title"]))
output(radio)
