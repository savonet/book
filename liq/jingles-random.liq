#!./liquidsoap
jingles = playlist("jingles")
music = playlist("~/Music")
radio = random([jingles, music.{weight = 4}])
output(radio)
