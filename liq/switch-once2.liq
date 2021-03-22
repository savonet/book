#!/usr/bin/env liquidsoap
music = playlist("~/Music")
ad    = playlist("ad-playlist")
radio = switch([
    (predicate.once({12h00-12h15}), ad),
    ({true},                        music)
  ])
output(radio)
