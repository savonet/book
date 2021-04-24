#!./liquidsoap
radio         = playlist("~/Music")
jingle_player = request.player()
radio         = add(normalize=false, [jingle_player, radio])
def jingles(~protocol, ~headers, ~data, uri)
  log.important("Serving #{uri}")
  let (uri, args) = url.split(uri)
  n = list.assoc(default="", "number", args)
  if n != "" then
    jingle_player.play(request.create("jingle#{n}.mp3"))
    http.response(data="Playing jingle.")
  else
    http.response(content_type="text/html",
                  data=file.contents("jingles.html"))
  end
end
harbor.http.register("/jingles", jingles)
output(radio)