#!./liquidsoap
def f(x)
  print("#{x} => #{json.stringify(x)}")
end
f(())
f(true)
f("abc")
f(23)
f(2.4)
f([2,3,4])
f((12,1.2))
l = [("f",1),("b",4)]
f(l)
# l = [("f",1),("b",4)]
# j = json.stringify (l)
# print("#{l} => #{j}")
f({x=1, y="a"})
# f(sine())
# f(ref(3))
# f(%mp3)
# f(fun () -> 5)