#!./liquidsoap
def rec whileloop(cond, f)
  c = to_bool_getter(cond)
  if c() then
    f()
    whileloop(cond, f)
  end
end
