#!/usr/bin/env liquidsoap
music = playlist("~/Music")
jingles = playlist("jingles")
radio = switch([
    ({00m-15m}, delay(1800., jingles)),
    ({true}, music)
  ])
output(radio)
