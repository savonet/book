#!./liquidsoap
jingles = playlist("jingles")
music = playlist("~/Music")
# header
radio = fallback([delay(1800., jingles), music])
# footer
output(radio)
