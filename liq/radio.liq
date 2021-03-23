#!./liquidsoap -i
day   = playlist("/radio/day.pls")   # Day music
night = playlist("/radio/night.pls") # Night music
mic   = buffer(input.alsa())         # Microphone
radio = switch([({8h-19h}, day), ({19h-20h}, mic), ({20h-8h}, night)])
jingles = playlist("/radio/jingls.pls") # Jingles
radio = crossfade(fade_out=3., fade_in=3., duration=5., radio)
radio = random(weights=[1, 4], [jingles, radio])
ignore(radio)
radio = playlist("~/Music")
radio = mksafe(radio)
# output(radio)
output.icecast(%mp3, host="localhost", port=8000, password="hackme", mount="my-radio.mp3", radio)
output.icecast(%fdkaac, host="localhost", port=8000, password="hackme", mount="my-radio.aac", radio)
