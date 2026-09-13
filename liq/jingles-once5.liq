#!/usr/bin/env liquidsoap
music = playlist("~/Music")
jingles = playlist("jingles")
# header
radio = switch([
    ({00m-15m}, delay(1800., jingles).{track_sensitive = false}),
    ({true}, music)
  ])
# footer
output(radio)
