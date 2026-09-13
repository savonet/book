#!/usr/bin/env liquidsoap
music = playlist("~/Music")
jingles = playlist("jingles")
# header
radio = switch([
    ({00m},  jingles),
    ({true}, music)
  ])
# footer
output(radio)
