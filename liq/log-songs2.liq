#!/usr/bin/env liquidsoap
def log_song(m)
  file.write(append=true, data="#{json_of(m)}\n", "/tmp/songs")
end

radio = playlist("~/Music")
radio.on_track(log_song)
output(radio)
