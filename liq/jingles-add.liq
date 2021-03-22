#!./liquidsoap
jingles = playlist("jingles")
music = playlist("~/Music")
radio = add([music, switch([({0m0s}, jingles)])])
output(radio)
