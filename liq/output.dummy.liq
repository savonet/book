#!./liquidsoap
s = mksafe(input.http("http://my/favorite/radio"))
def log_song(m)
  file.write(append=true, data=metadata.json.stringify(m), "/tmp/songs")
end
s.on_track(log_song)
output.dummy(s)
