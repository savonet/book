#!./liquidsoap
def rec whileloop(cond, f)
  if getter.get(cond) then
    f()
    whileloop(cond, f)
  end
end
