#!./liquidsoap
def check(r)
  m = request.metadata(r)
  m["genre"] == "Rock"
end
s = playlist(check_next=check, "~/Music")
output(s)
