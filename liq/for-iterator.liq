n = ref(0)
for i = list.iterator([1,2,3,4,5,6,7,8,9,10]) do
  n := n() + i
end
print(n())
