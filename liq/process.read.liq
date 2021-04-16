#!./liquidsoap
n = process.read("find ~/Music -type f | wc -l")
n = int_of_string(string.trim(n))
print("We have #{n} files in the library.")
