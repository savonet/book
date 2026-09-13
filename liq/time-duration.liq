#!./liquidsoap
f = fun() -> ignore(list.init(100000, fun(i)->i*i))
# header
t = time()
f()
d = time() - t
print("The execution of f took #{d} s.")
