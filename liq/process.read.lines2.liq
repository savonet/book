#!./liquidsoap
l = process.read.lines("find ~/Music -type f")
l = list.shuffle(l)
print("We are going to play #{list.length(l)} files.")
s = playlist.list(l)
output(s)
