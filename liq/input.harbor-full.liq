#!/usr/bin/env liquidsoap
# header
playlist = playlist("~/Music")
live     = input.harbor("live", port=8000, password="hackme")
radio    = fallback([live, playlist])
output(radio)
