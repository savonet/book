#!./liquidsoap
def request.queue.pushable(~id="", ~queue=[])
  queue = ref(queue)
  def next()
    r = list.hd(default=request.create(""), !queue)
    queue := list.tl(!queue)
    log.info(label=id, "Next song will be #{request.uri(r)}.")
    r
  end
  def push(uri)
    log.info(label=id, "Pushing #{uri} on the queue.")
    queue := list.append(!queue, [uri])
  end
  s = request.dynamic(id=id, available={not list.is_empty(!queue)}, next)
  (push, s)
end
out(snd(request.queue.pushable(queue=[request.create("test.mp3")])))
