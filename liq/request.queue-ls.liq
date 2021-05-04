#!./liquidsoap
q = request.queue()
def play(file)
  r = request.create(file)
  q.push(r)
end
list.iter(play, file.ls(pattern="*.mp3", "."))
output(q)
