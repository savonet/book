#!./liquidsoap
# header
volume = ref(0.)

def change()
  print("Changing state.")
  atomic({volume := 1. - volume()})
end
thread.run(every=1., change)

s = amplify(volume, sine())
output(s)
