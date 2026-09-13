#!./liquidsoap
s = normalize(playlist("~/Music"))
# header
s = ladspa.fastlookaheadlimiter(limit=-3., s)
# footer
output(s)
