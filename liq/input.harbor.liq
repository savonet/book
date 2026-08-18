#!/usr/bin/env liquidsoap
playlist = playlist("~/Music")
live     = input.harbor("live", port=8000, password="hackme")
radio    = fallback([live, playlist])
output(radio)
