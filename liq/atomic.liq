#!/usr/bin/env liquidsoap
volume = ref(0.)
# header
atomic({volume := 1. - volume()})
# footer
output(amplify(volume, sine()))
