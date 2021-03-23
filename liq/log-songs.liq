#!/usr/bin/env liquidsoap
def log_song(m)
  artist = m["artist"]
  title  = m["title"]
  file.write(append=true, data="#{artist} - #{title}\n", "/tmp/songs")
end

radio = playlist("~/Music")
radio.on_track(log_song)
output(radio)
