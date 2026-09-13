#!./liquidsoap
jingles = playlist("jingles")
music = playlist("~/Music")
# header
radio = add([delay(1800., jingles), music])
# footer
output(radio)
