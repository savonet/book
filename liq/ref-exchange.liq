#!./liquidsoap
r = ref(5)
# header
old = r.exchange(7)
# footer
print(string(old))
