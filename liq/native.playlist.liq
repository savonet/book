#!./liquidsoap
s = playlist(native=true, "~/Music")
s.on_track(fun (m) -> print(json_of(m)))
output(s)
