#!./liquidsoap --safe
s = request.player()
output(s)
def new()
  s.play(request.create("synth:shape=sine,amplitude=#{random.float(min=0.,max=1.)},duration=#{random.float(min=0.,max=5.)},frequency=#{random.float(min=200.,max=1000.)}"))
end
thread.run(every={random.float(min=0., max=2.)}, new)