#!./liquidsoap
on = ref(false)
s = switch(track_sensitive=false, [({!on}, sine()), ({true}, blank())])
def change()
  print("Changing state.")
  on := not(!on)
  1.
end
thread.run.recurrent(change)
out(s)

