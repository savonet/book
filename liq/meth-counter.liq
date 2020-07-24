n = ref(0)
def counter()
  n := !n + 1
  !n
end
def counter.reset()
  n := 0
end

ignore(counter())
ignore(counter())
t(counter(), 3)
counter.reset()
t(counter(), 1)
