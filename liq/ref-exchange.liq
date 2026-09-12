#!./liquidsoap
r = ref(5)
old = r.exchange(7)
print(string(old))
