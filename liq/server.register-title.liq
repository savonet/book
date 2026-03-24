#!./liquidsoap
radio = playlist("~/Music")
server.telnet()
def on_title(t)
  radio.insert_metadata([("title", t)])
  "Title set to #{t}."
end
server.register(usage="title <new title>",
                description="Set the title of the radio.",
                "title", on_title)
output(radio)
