#!./liquidsoap
s = playlist("~/Music")
s = amplify({if s.time() mod 10. <= 5. then 1. else 0. end}, s)
# header
s = blank.skip(max_blank=2., s)
# footer
output(s)
