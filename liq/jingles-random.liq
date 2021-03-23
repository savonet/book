#!./liquidsoap
jingles = playlist("jingles")
music = playlist("~/Music")
radio = rotate(weights=[1, 4], [jingles, music])
output(radio)
