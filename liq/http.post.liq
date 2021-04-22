#!./liquidsoap
log.level.set(5)
radio = playlist("~/Music")
def handle_metadata(m)
  h = http.post(
        headers=[("Content-Type", "application/json; charset=UTF-8")],
        data=json_of(m),
        "http://our.website.com/update_metadata.php")
  if h.status_code >= 400 then
    log.important("Failed to update metadata.")
  end
end
radio.on_track(handle_metadata)
output(radio)
