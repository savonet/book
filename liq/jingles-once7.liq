#!/usr/bin/env liquidsoap
music = playlist("~/Music")
jingles = playlist("jingles")
radio = switch([
# header
    (predicate.once({00m-15m or 30m-45m}), jingles),
# footer
    ({true},                    music)
  ])
output(radio)
