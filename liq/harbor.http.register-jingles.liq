#!./liquidsoap
radio        = playlist("~/Music")
jingle_queue = request.queue()
radio        = add(normalize=false, [jingle_queue, radio])
def jingles(~protocol, ~headers, ~data, uri)
  log.important("Serving #{uri}")
  let (uri, args) = url.split(uri)
  n = list.assoc(default="", "number", args)
  if n != "" and string.is_int(n) then
    jingle_queue.push(request.create("jingle#{n}.mp3"))
    http.response(data="Playing jingle.")
  else
    http.response(content_type="text/html",
                  data=file.contents("jingles.html"))
  end
end
harbor.http.register("/jingles", jingles)
output(radio)