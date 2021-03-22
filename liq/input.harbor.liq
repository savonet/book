#!/usr/bin/env liquidsoap
playlist = playlist("~/Music")
live     = input.harbor("live", port=8000, password="hackme")
radio    = fallback(track_sensitive=false, [live, playlist])
output(radio)
