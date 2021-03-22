#!./liquidsoap
jingles = playlist("jingles")
music = playlist("~/Music")
radio = switch([delay(1200., jingles), music])
output(radio)
