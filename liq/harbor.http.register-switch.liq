#!./liquidsoap
rap = sine(880.) rock = sine(440.) techno = sine(220.) server.harbor()
selected = ref("techno")
def on_select(request)
  selected := request.query["source"]
  http.response(data="Source #{selected()} selected.")
end
harbor.http.register.simple("/select", on_select)
radio = switch(track_sensitive=false, [
  ({selected() == "rap"},    rap),
  ({selected() == "rock"},   rock),
  ({selected() == "techno"}, techno)
])
output(radio)
