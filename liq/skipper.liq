#!./liquidsoap
s = skipper(every=5., playlist(native=true, "~/Music"))
s.on_track(fun (m) -> print(json_of(m)))
output(s)
