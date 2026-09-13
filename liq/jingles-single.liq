#!./liquidsoap
jingles = playlist("jingles")
music = playlist("~/Music")
# header
radio = rotate([jingles.{single = true}, music.{weight = 4}])
# footer
output(radio)
