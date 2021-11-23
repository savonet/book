#!/usr/bin/env liquidsoap
radio = playlist("~/Music")
def log_song(m)
  file.write(append=true, data="#{metadata.json.stringify(m)}\n", "/tmp/songs")
end

radio.on_track(log_song)
output(radio)
