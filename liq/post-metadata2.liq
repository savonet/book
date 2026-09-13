#!./liquidsoap
radio = playlist("~/Music")
def handle_metadata(m)
  _ = http.post(data=metadata.json.stringify(m),
        headers=[("Content-Type", "application/json; charset=UTF-8")],
        "http://our.website.com/update_metadata.php")
end
# header
radio.on_track(synchronous=false, handle_metadata)
# footer
output(radio)
