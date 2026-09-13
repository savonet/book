#!./liquidsoap
# header
def loop()
  for i = 1 to 250 do
    ignore(request.create("test.mp3"))
  end
end
thread.run(delay=1., loop)
# footer
output.dummy(blank())
