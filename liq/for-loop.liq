#!./liquidsoap
def rec forloop(first, last, f)
  if first <= last then
    f(first)
    forloop(first+1, last, f)
  end
end
forloop(0, 4, fun(i) -> print("This is number #{i}."))
