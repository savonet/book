#!./liquidsoap
radio = playlist("~/Music")
last_metadata = ref([])
radio.on_track(fun (m) -> last_metadata := m)
def show_metadata(_)
  http.response(content_type="application/json; charset=UTF-8",
                data=metadata.json.stringify(last_metadata()))
end
harbor.http.register.simple("/metadata", show_metadata)
thread.run(every=3., {radio.skip()}) output(radio)