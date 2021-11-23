#!/usr/bin/env liquidsoap
s = playlist(prefix="annotate:jingle=true:", "~/Music")
s.on_track(fun(m) -> print(json.stringify(m))); output(s)
