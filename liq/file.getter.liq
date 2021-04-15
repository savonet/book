#!./liquidsoap
f = file.getter("playlist")
print(f())
output.dummy(blank())