#!/usr/bin/env liquidsoap
music = playlist("~/Music")
jingles = playlist("jingles")
radio = switch([
# header
    ({00m-15m}, once(jingles)),
# footer
    ({true}, (music : source))
  ])
output(radio)
