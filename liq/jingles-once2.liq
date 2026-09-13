#!/usr/bin/env liquidsoap
music = playlist("~/Music")
jingles = playlist("jingles")
radio = switch([
# header
    ({00m-15m}, jingles),
# footer
    ({true}, music)
  ])
output(radio)
