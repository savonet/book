#!./liquidsoap
def request.queue(~id="", ~queue=[])
  queue = ref(queue)
  def next()
    if not list.is_empty(!queue) then
      r      = list.hd(!queue)
      queue := list.tl(!queue)
      log.info(label=id, "Next song will be #{request.uri(r)}.")
      r
    else
      null()
    end
  end
  def push(r)
    log.info(label=id, "Pushing request #{r} on the queue.")
    queue := list.append(!queue, [r])
  end
  s = request.dynamic(available={not list.is_empty(!queue)}, next)
  s.{ push=push }
end
output(request.queue(queue=[request.create("test.mp3")]))
