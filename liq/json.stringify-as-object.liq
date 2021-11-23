#!./liquidsoap
l = [("f", 1), ("b", 4)]
let json.stringify j = (l : [(string * int)] as json.object)
print("#{l} => #{j}")
