#!./liquidsoap
def vol()
  if time.up() mod 10. <= 5. then 1.
  else 0. end
end
s = amplify(vol, playlist("~/Music"))
s = blank.strip(max_blank=2., s)
s = fallback(track_sensitive=false, [s, sine()])
output(s)
