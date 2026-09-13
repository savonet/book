#!./liquidsoap
jingles = playlist("jingles")
music = playlist("~/Music")
# header
radio = rotate([jingles, music.{weight = 4}])
# footer
output(radio)
