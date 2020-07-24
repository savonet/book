h = http.get("http://www.google.fr/xxx")
if h.status_code == 404 then
  print("The page was not foud")
else
  print("Contents of the webpage: " ^ h)
end
