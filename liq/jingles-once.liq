#!/usr/bin/env liquidsoap
music = playlist("~/Music")
jingles = playlist("jingles")
radio = switch([
    ({00m},  jingles),
    ({true}, music)
  ])
output(radio)
