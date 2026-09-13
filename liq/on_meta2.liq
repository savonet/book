#!./liquidsoap
radio = playlist("~/Music")
# header
radio.on_metadata(synchronous=true, fun (m) -> print(m["title"]))
# footer
output(radio)
