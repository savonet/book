#!/usr/bin/env liquidsoap
# header
s = playlist(prefix="annotate:jingle=true:", "~/Music")
# footer
s.on_track(synchronous=true, fun(m) -> print(metadata.json.stringify(m))); output(s)
