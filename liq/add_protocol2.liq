#!/usr/bin/env liquidsoap
def artist_protocol(~rlog,~maxtime,arg) =
  ["process:./find_by_artist #{string.quote(arg)}"]
end
add_protocol(static=true,"artist",artist_protocol)

s = audio_to_stereo(single("artist:Haliday"))
out(s)
