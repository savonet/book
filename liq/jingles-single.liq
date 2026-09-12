#!./liquidsoap
jingles = playlist("jingles")
music = playlist("~/Music")
radio = rotate([jingles.{single = true}, music.{weight = 4}])
output(radio)
