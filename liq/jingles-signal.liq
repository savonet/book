#!./liquidsoap
music = chop(playlist("~/Music"))
jingles = playlist("jingles")
p = predicate.signal()
radio = switch([(p, jingles), ({true}, music)])
thread.run(every=1200., {p.signal()})
output(radio)
