#!./liquidsoap --safe
radio        = playlist("~/Music")
jingle_queue = request.queue()
radio        = add(normalize=false, [jingle_queue, radio])
def jingles(req)
  n = req.query["number"]
  if n != "" and string.is_int(n) then
    log.important("Playing jingle #{n}.")
    jingle_queue.push(request.create("jingle#{n}.mp3"))
    http.response(data="Playing jingle.")
  else
    http.response(content_type="text/html",
                  data=file.contents("jingles.html"))
  end
end
harbor.http.register.simple("/jingles", jingles)
output(radio)