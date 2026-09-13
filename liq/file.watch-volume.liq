#!./liquidsoap
radio  = playlist("~/Music")
# header
volume = ref(1.)
radio  = amplify(volume, radio)
def update()
  v = string.trim(file.contents("volume"))
  volume := float_of_string(v)
  log.important("New volume is #{volume()}.")
end
file.watch("volume", update)
# footer
output(radio)
thread.run(delay=2., {process.run("touch volume")})
