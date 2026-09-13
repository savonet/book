#!./liquidsoap
log.level := 5
# header
harbor.http.static(port=8000, path="/music", browse=true, "~/Music")
# footer
output(blank())
