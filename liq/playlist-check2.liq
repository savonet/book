#!./liquidsoap
def check(r)
  m = file.metadata(request.uri(r))
  m["genre"] == "Rock"
end
s = playlist(check_next=check, "~/Music")
output(s)
