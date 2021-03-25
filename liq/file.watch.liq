#!./liquidsoap
def update()
  v = file.contents("volume")
  print("New volume is #{v}.")
end
ignore(file.watch("volume", update))
output.dummy(blank())
