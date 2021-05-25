#!./liquidsoap
radio = playlist("~/Music")
def handle_metadata(m)
  _ = http.post(data=json_of(m),
        headers=[("Content-Type", "application/json; charset=UTF-8")],
        "http://our.website.com/update_metadata.php")
end
radio.on_track(handle_metadata)
output(radio)
