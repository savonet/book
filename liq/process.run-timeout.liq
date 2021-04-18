#!./liquidsoap
t0 = time()
p = process.run(timeout=1., "sleep 3")
t = time() - t0
print("Program ended in #{t} seconds: #{p.status} #{p.status.code}")
