#!./liquidsoap
rap = sine(880.) rock = sine(440.) techno = sine(220.) server.harbor()
set("server.telnet", true)
selected = ref("techno")
def on_select(x)
  selected := x
  "Source #{x} selected."
end
server.register(usage="select <rap/rock/techno>",
                description="Switch between our music sources.",
                "select", on_select)
radio = switch(track_sensitive=false, [
  ({!selected == "rap"},    rap),
  ({!selected == "rock"},   rock),
  ({!selected == "techno"}, techno)
])
output(radio)
