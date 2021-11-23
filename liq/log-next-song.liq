#!./liquidsoap
def log_next(r)
  m = request.metadata(r)
  file.write(data="#{json.stringify(m)}", "/tmp/next-song")
  true
end

radio = playlist("~/Music", length=40., check_next=log_next)
output(radio) server.harbor() log.level.set(5)
