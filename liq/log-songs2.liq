#!/usr/bin/env liquidsoap
radio = playlist("~/Music")
# header
def log_song(m)
  file.write(append=true, data="#{metadata.json.stringify(m)}\n",
             "/tmp/songs")
end
# footer

radio.on_track(synchronous=false, log_song)
output(radio)
