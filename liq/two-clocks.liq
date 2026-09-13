#!/usr/bin/env liquidsoap
jingles = playlist("~/jingles")
# header
output(mksafe(fallback([crossfade(playlist("~/Music")), jingles])))
