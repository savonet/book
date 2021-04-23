#!./liquidsoap
s = request.player()
def note()
  r = "synth:frequency=#{random.float(min=200.,max=800.)},duration=#{random.float(min=2.,max=6.)}"
  log.important("Playing #{r}")
  r
end
thread.run(every={random.float(min=0.,max=2.)}, {s.play(request.create(note()))})
output(s)
output.file(%mp3, "/tmp/robot.mp3", mksafe(s))