#!./liquidsoap
# header
def log_next(r)
  m = request.metadata(r)
  file.write(data="#{metadata.json.stringify(m)}", "/tmp/next-song")
  true
end

radio = playlist("~/Music", check_next=log_next)
# footer
output(radio)
server.harbor()
log.level := 5
