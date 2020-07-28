#!./liquidsoap
volume = ref(0.)

def change()
  print("Changing state.")
  volume := 1. - !volume
end
thread.run(every=1., change)

s = amplify({!volume}, sine())
output(s)
