#!./liquidsoap
# header
ice_server = icecast.server({source_password = "hackme"})

ice_server.on_listener_connect(
  fun (listener) ->
    log.important(
      "Listener #{listener.id} tuned in to #{listener.mount}"
    )
)

ice_server.on_listener_disconnect(
  fun (listener) ->
    log.important(
      "Listener #{listener.id} left #{listener.mount} after #{
        int(listener.duration)
      }s"
    )
)

ice_server.on_metadata(
  fun (update) ->
    log.important(
      "Now playing on #{update.mount}: #{update.metadata["title"]}"
    )
)
