#!./liquidsoap
log.level := 5
harbor.http.static(path="/pages", "www")
output(blank())