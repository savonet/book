#!./liquidsoap
p = process.run(timeout=2., "sleep 10")
print("Program ended: #{p.status} #{p.status.code}")
