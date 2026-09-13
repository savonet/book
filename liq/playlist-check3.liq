#!./liquidsoap
# header
def check(f)
  m = file.metadata(f)
  if m["genre"] == "Dance" then
    print("Keeping #{f}.")
    true
  else
    false
  end
end
l = playlist.files("~/Music/misc")
l = list.filter(check, l)
s = playlist.list(l)
# footer
output(s)
