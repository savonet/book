#!/usr/bin/env liquidsoap
h = http.get("http://www.google.fr/xxx")
if h.status_code == 404 then print("The page was not found")
else print("Contents of the webpage: " ^ h) end
