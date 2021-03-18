#!./liquidsoap
s = playlist("~/Music")
s.on_track(fun(_) -> print("New track in the source!"))
output(blank())
