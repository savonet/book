#!./liquidsoap
# header
ice_server =
  icecast.server(
    {
      source_password = "hackme",
      admin_password = "admin-secret",
      access_log = "/var/log/liquidsoap/access.log",
      playlist_log = "/var/log/liquidsoap/playlist.log",
      error_log = "/var/log/liquidsoap/error.log"
    }
  )

ignore(on_signal("hup", fun () -> ice_server.reopen_logs()))
