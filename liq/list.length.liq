def rec length(l)
  if l == [] then 0
  else 1 + length(list.tl(l)) end
end