#!./liquidsoap
set("server.telnet", true)
music = chop(playlist("~/Music"))
jingles = playlist("jingles")
p = predicate.signal()
radio = switch([(p, jingles), ({true}, music)])
def cmd(_)
  p.signal()
  "Jingle inserted!"
end
server.register("insert_jingle", cmd)
output(radio)
