#!/usr/bin/env liquidsoap
music = playlist("~/Music")
jingles = playlist("jingles")
radio = switch([
# header
    (predicate.at_most(3, {00m-15m}), jingles),
# footer
    ({true},                    music)
  ])
output(radio)
