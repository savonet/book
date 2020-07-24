def list.hd(l)
  if l == [] then null() else list.hd(l) end
end
l = ["a","b","c"]
x = list.hd(l)
print("the head is " ^ (x ?? "not defined"))
