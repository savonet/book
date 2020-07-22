def rec while(cond, f)
  c = to_bool_getter(cond)
  if c() then
    f()
    while(cond, f)
  end
end
