#!/usr/bin/env liquidsoap
morning = sine()
evening = sine()
music   = sine()
# header
radio = switch([
    ({6h-9h},   morning),
    ({20h-24h}, evening),
    ({true},    music)
  ])
# footer
output(radio)
