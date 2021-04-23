#!./liquidsoap
rap = sine(880.) rock = sine(440.) techno = sine(220.) server.harbor()
selected = ref("techno")
def on_select(~protocol, ~headers, ~data, uri)
  let (uri, args) = url.split(uri)
  selected := args["source"]
  http.response(data="Source #{!selected} selected.")
end
harbor.http.register("/select", on_select)
radio = switch(track_sensitive=false, [
  ({!selected == "rap"},    rap),
  ({!selected == "rock"},   rock),
  ({!selected == "techno"}, techno)
])
output(radio)
