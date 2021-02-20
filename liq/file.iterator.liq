#!./liquidsoap
fname = "test.txt"
f = file.lines.iterator(fname)
for contents = f do
  print(contents)
end
