f = file.read("test.txt")
r = ref(f())
while !r != "" do
  print(newline=false, !r)
  r := f()
end