#!/usr/bin/env liquidsoap
h = http.get("http://www.google.fr/xxx")
if h.status_code < 400 then
  print("Contents of the webpage: #{h}")
else
  print("An error occured: #{h.status_code} (#{h.status_message})")
end
