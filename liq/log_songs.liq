#!/usr/bin/env liquidsoap
radio = playlist("~/Music")

def log_song(m) =
  artist = m["artist"]
  title = m["title"]
  ignore(file.write(append=true, data="#{artist} - #{title}\n", "/tmp/songs"))
end

radio = on_metadata(log_song, radio)
out(radio)
