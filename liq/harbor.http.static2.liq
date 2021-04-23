#!./liquidsoap
log.level.set(5)
harbor.http.static(path="/pages", "www")
output(blank())