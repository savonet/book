#!./liquidsoap
s = playlist("~/Music")
s.on_track(synchronous=true, fun(_) -> print("New track in the source!"))
output(blank())
