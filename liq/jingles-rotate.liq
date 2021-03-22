#!./liquidsoap
jingles = playlist("jingles")
music = playlist("~/Music")
radio = rotate(weights=[4,1], [music, jingles])
output(radio)
