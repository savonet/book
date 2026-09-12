#!./liquidsoap
def double((volume : getter(float)))
  getter.get(volume) * 2.
end
print(string(double(1.5)))
print(string(double({1.5})))
