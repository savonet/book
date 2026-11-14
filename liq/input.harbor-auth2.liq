#!./liquidsoap
# header
def auth(login)
  process.test(
    process.quote.command(args=[login.user, login.password], "./harbor-auth")
  )
end
s = input.harbor("live", auth=auth)
# footer
output(s)
