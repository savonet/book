#!./liquidsoap
log.level := 5
harbor.http.static(port=8000, path="/music", browse=true, "~/Music")
output(blank())