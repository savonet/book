#!./liquidsoap
server.telnet()
sources = ref([])
def play(pl)
  s = mksafe(playlist("playlists/#{pl}"))
  s = output.icecast(%mp3, mount="#{pl}", s)
  sources := list.add((pl, s), !sources)
  "Playing #{pl}."
end
def stop(pl)
  s = list.assoc(pl, !sources)
  sources := list.assoc.remove(pl, !sources)
  s.shutdown()
  "Stopped #{pl}."
end
server.register("play", play)
server.register("stop", stop)
output.dummy(blank())