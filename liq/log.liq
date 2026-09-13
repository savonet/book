#!./liquidsoap
thread.run(delay=1., fun () ->
# header
log.severe(label="testing", "This is my message to you.")
# footer
)
output.dummy(blank())
