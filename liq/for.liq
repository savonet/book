def rec for(first, last, f)
  if first <= last then
    f(first)
    for(first+1, last, f)
  end
end
for(0, 4, fun(i) -> print("This is number #{i}."))
