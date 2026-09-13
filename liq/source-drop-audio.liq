#!/usr/bin/env liquidsoap
# header
def source.drop.audio(~id=null, s) =
  let {audio = _, ...tracks} = source.tracks(s)
  source(id=id, tracks)
end
