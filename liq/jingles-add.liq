#!./liquidsoap
# header
jingles = playlist("jingles")
# footer
music = playlist("~/Music")
radio = add([music, switch([({0m0s}, jingles)])])
output(radio)
