#!/usr/bin/env liquidsoap
s1 = sine()
s2 = sine(440. * pow(2., 3. / 12.))
s3 = sine(440. * pow(2., 7. / 12.))
s  = add([s1, s2, s3])
out(s)