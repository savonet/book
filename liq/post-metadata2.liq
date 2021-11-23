#!./liquidsoap
radio = playlist("~/Music")
def handle_metadata(m)
  _ = http.post(data=metadata.json.stringify(m),
        headers=[("Content-Type", "application/json; charset=UTF-8")],
        "http://our.website.com/update_metadata.php")
end
radio.on_track(fun(m) -> thread.run({handle_metadata(m)}))
output(radio)
