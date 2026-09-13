#!./liquidsoap
log.level := 5
# header
harbor.http.static(path="/pages", "www")
# footer
output(blank())
