#!/usr/bin/env liquidsoap
music = playlist("~/Music")
jingles = playlist("jingles")
# header
radio = switch([
    (predicate.once({00m-15m}), jingles),
    ({true},                    music)
  ])
# footer
output(radio)
