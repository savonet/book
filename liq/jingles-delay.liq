#!./liquidsoap
jingles = playlist("jingles")
music = playlist("~/Music")
radio = fallback([delay(1800., jingles), music])
output(radio)
