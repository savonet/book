#!./liquidsoap
# header
transport = http.transport.ssl(certificate="server.crt", key="server.key")
s = input.harbor("live", port=8000, transport=transport)
# footer
output(s)
