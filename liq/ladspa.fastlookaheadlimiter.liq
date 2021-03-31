#!./liquidsoap
s = normalize(playlist("~/Music"))
s = ladspa.fastlookaheadlimiter(limit=-3., s)
output(s)
