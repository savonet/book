#!/usr/bin/env liquidsoap
music = playlist("~/Music")
jingles = playlist("jingles")
radio = switch(track_sensitive=false, [
    ({00m-15m}, delay(1800., jingles)),
    ({true}, music)
  ])
output(radio)
