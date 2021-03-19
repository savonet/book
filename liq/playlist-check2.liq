#!./liquidsoap
def check(r)
  request.read_metadata(r)
  m = request.metadata(r)
  m["genre"] == "Rock"
end
s = playlist(check_next=check, "~/Music")
output(s)
