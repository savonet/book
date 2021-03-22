#!/usr/bin/env liquidsoap
music = playlist("~/Music")
ad    = playlist("ad-playlist")
radio = switch([
    ({12h00-12h00}, ad),
    ({true},        music)
  ])
output(radio)
