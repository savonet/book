#!./liquidsoap
rap = sine(880.) rock = sine(440.) techno = sine(220.) server.harbor()
server.telnet()
selected = ref("techno")
def on_select(x)
  selected := x
  "Source #{x} selected."
end
server.register(usage="select <rap/rock/techno>",
                description="Switch between our music sources.",
                "select", on_select)
radio = switch([
  ({selected() == "rap"},    rap.{track_sensitive = false}),
  ({selected() == "rock"},   rock.{track_sensitive = false}),
  ({selected() == "techno"}, techno.{track_sensitive = false})
])
output(radio)
