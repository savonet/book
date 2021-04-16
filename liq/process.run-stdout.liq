#!./liquidsoap
p = process.run("ls -R ~/Music | wc -l")
if p.status == "exit" and p.status.code == 0 then
  n = int_of_string(string.trim(p.stdout))
  print("We have #{n} files in the library.")
end