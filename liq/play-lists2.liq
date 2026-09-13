#!./liquidsoap
# header
server.telnet()
sources = ref([])
def play(pl)
  s = mksafe(playlist("playlists/#{pl}"))
  s = output.icecast(%mp3, mount="#{pl}", s)
  atomic({sources := list.add((pl, s), sources())})
  "Playing #{pl}."
end
def stop(pl)
  def remove()
    s = list.assoc(pl, sources())
    sources := list.assoc.remove(pl, sources())
    s
  end
  s = atomic(remove)
  s.shutdown()
  "Stopped #{pl}."
end
server.register("play", play)
server.register("stop", stop)
# footer
output.dummy(blank())
