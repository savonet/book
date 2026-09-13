#!./liquidsoap
music = chop(playlist("~/Music"))
jingles = playlist("jingles")
# header
p = predicate.signal()
radio = switch([(p, jingles), ({true}, music)])
thread.run(every=1200., {p.signal()})
# footer
output(radio)
