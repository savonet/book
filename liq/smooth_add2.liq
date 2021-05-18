#!./liquidsoap
jingles = delay(1800., playlist("jingles"))
music = playlist("~/Music")
radio = smooth_add(duration=0.5, special=jingles, normal=music)
output(radio)
