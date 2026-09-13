#!./liquidsoap
jingles = playlist("jingles")
music = playlist("~/Music")
# header
radio = random([jingles, music.{weight = 4}])
# footer
output(radio)
