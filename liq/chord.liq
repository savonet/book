#!/usr/bin/env liquidsoap
def note(n) = sine(440. * pow(2., n / 12.)) end
s = add(list.map(note, [0., 3., 7.]))
output(s)
