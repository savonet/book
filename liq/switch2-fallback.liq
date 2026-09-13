#!/usr/bin/env liquidsoap
morning = sine()
evening = sine()
music   = sine()
# header
radio = switch([({6h-9h}, morning), ({20h-24h}, evening)])
radio = fallback([radio, music])
# footer
output(radio)
