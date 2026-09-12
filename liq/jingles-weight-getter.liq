#!./liquidsoap
jingles = playlist("jingles")
music = playlist("~/Music")
radio = rotate([jingles, music.{weight = {(0h-6h) ? 8 : 4}}])
output(radio)
