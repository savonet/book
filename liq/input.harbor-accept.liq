#!./liquidsoap
# header
def accept(client) =
  if
    client.method == "GET"
  then
    {refuse = {status = 403, reason = "Metadata updates are not allowed"}}
  else
    null
  end
end

s = input.harbor("live", port=8000, password="hackme", accept=accept)
# footer
output(s)
