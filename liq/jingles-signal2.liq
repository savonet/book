#!./liquidsoap
server.telnet()
music = chop(playlist("~/Music"))
jingles = playlist("jingles")
p = predicate.signal()
radio = switch([(p, jingles), ({true}, music)])
# header
def cmd(_)
  p.signal()
  "Jingle inserted!"
end
server.register("insert_jingle", cmd)
# footer
output(radio)
