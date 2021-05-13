#!./liquidsoap
n = ref(0)
def f() =
  for i = 1 to 10000 do
    n := !n + 1
  end
  print("Thread over")
end
for i = 1 to 10 do
  print("Lanch thread #{i}")
  thread.run(f)
end
thread.run(delay=1., {print(!n)})
output.dummy(blank())