#!./liquidsoap
morning = sine()
default = sine()
s = switch([({6h-10h},morning), ({true},default)])
s = amplify(0.8, s)
output.icecast(%mp3, mount="...", s) 