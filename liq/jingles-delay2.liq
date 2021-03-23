#!./liquidsoap
jingles = playlist("jingles")
music = playlist("~/Music")
radio = add([delay(1800., jingles), music])
output(radio)
