#!/usr/bin/env liquidsoap
def artist_protocol(~rlog, ~maxtime, arg) =
  rlog("Finding songs of #{arg}.")
  process.read.lines("find_by_artist #{string.quote(arg)}")
end
add_protocol("artist", artist_protocol,
             doc="Find songs by artist.",
             syntax="artist:<arist name>")

s = single("artist:Haliday")
output(s)
