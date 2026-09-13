#!./liquidsoap
jingles = playlist("jingles")
music = playlist("~/Music")
# header
radio = rotate([jingles, music.{weight = {(0h-6h) ? 8 : 4}}])
# footer
output(radio)
