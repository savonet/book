#!./liquidsoap
p = process.run("my-prog")
if p.status == "exit" and p.status.code == 0 then
  print("The program exited normally.")
else
  print("An error happened while running the program: \
         #{p.status} #{p.status.code}.")
end
