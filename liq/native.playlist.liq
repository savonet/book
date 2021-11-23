#!./liquidsoap
s = playlist(native=true, "~/Music")
s.on_track(fun (m) -> print(metadata.json.stringify(m)))
output(s)
