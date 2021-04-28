#!./liquidsoap
pls = file.ls("playlists/")
def play(list)
  log.important("Playing #{list}.")
  s = mksafe(playlist("playlists/#{list}"))
  ignore(output.icecast(%mp3, mount="#{list}", s))
end
list.iter(play, pls)
