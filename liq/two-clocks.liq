#!/usr/bin/env liquidsoap
jingles = playlist("~/jingles")
output(mksafe(fallback([crossfade(playlist("~/Music")), jingles])))
