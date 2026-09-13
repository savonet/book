#!/usr/bin/env liquidsoap
# header
def log_song(m)
  artist = m["artist"]
  title  = m["title"]
  file.write(append=true, data="#{artist} - #{title}\n", "/tmp/songs")
end

radio = playlist("~/Music")
radio.on_track(synchronous=false, log_song)
# footer
output(radio)
