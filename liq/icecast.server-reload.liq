#!./liquidsoap
# header
config = "/etc/icecast2/icecast.xml"

def parameters() =
  icecast.server.config.load(config)
end

ice_server = icecast.server(parameters())

def reload() =
  try
    ice_server.reload(parameters())
  catch err do
    log.important(
      "Configuration not reloaded: #{err.message}"
    )
  end
end

ignore(
  on_signal(
    "hup",
    fun () ->
      begin
        reload()
        ice_server.reopen_logs()
      end
  )
)
