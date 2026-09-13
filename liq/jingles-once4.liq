#!/usr/bin/env liquidsoap
music = playlist("~/Music")
jingles = playlist("jingles")
radio = switch([
# header
    ({00m-15m}, delay(1800., jingles)),
# footer
    ({true}, music)
  ])
output(radio)
