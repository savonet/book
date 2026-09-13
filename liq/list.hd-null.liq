def list.hd(l)
  if l == [] then null else list.hd(l) end
end
# footer-a
l = ["a","b","c"]
# header-b
x = list.hd(l)
print("the head is " ^ (x ?? "not defined"))
