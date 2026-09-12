#!./liquidsoap
state = ref({volume = 1., muted = false})

def mute()
  state := {volume = 0., muted = true}
end
thread.run(delay=10., mute)

s = amplify({state().volume}, sine())
output(s)
