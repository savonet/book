#!/usr/bin/env liquidsoap
music = playlist("~/Music")
jingles = playlist("jingles")
radio = switch([
    ({00m-15m}, jingles),
    ({true}, music)
  ])
output(radio)
