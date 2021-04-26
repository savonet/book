#!./liquidsoap
thread.run(delay=1., fun () ->
log.severe(label="testing", "This is my message to you.")
)
output.dummy(blank())