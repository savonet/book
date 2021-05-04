#!./liquidsoap
def loop()
  for i = 1 to 250 do
    ignore(request.create("test.mp3"))
  end
end
thread.run(delay=1., loop)
output.dummy(blank())
