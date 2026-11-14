#!./liquidsoap
# header
def auth(login)
  ans =
    process.read.lines(
      process.quote.command(args=[login.user, login.password], "./harbor-auth")
    )
  if list.hd(default="", ans) == "allowed" then
    true
  else
    log.important("Invalid login from #{login.user}")
    false
  end
end
s = input.harbor("live", port=8000, auth=auth)
output(s)
