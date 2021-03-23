#!/usr/bin/env liquidsoap
morning = sine()
evening = sine()
music   = sine()
radio = switch([
    ({6h-9h},   morning),
    ({20h-24h}, evening),
    ({true},    music)
  ])
output(radio)
