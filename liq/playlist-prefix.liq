#!/usr/bin/env liquidsoap
s = playlist(prefix="annotate:jingle=true:", "~/Music")
s.on_track(synchronous=true, fun(m) -> print(metadata.json.stringify(m))); output(s)
