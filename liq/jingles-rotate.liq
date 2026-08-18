#!./liquidsoap
jingles = playlist("jingles")
music = playlist("~/Music")
radio = rotate([jingles, music.{weight = 4}])
output(radio)
