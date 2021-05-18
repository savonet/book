#!./liquidsoap
jingles = delay(1800., playlist("jingles"))
music = playlist("~/Music")
radio = add([jingles, music])
output(radio)
