#!./liquidsoap
ignore(
# header-a
server.execute("title My new title")
# footer-a
)
ignore(
# header-b
server.execute("title", "My new title")
# footer-b
)
