#!./liquidsoap
def next()
  uri = file.contents("song")
  if uri != "" then
    request.create(uri)
  else
    null()
  end
end
s = request.dynamic(retry_delay=1., next)
output(s)