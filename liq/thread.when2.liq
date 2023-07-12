#!./liquidsoap
log.level := 4
q    = request.queue()
def read_time()
  text = time.string("It is %H hours, %M minutes and %S seconds")
  q.push(request.create("say:#{text}"))
end
thread.when({0m}, read_time)
output(q)