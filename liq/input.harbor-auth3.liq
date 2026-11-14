#!./liquidsoap
# header
settings.sandbox := true
def auth(login)
  p =
    process.run(
      rodirs=["/users"],
      rwdirs=[],
      network=false,
      process.quote.command(args=[login.user, login.password], "./harbor-auth")
    )
  p.status == "exit" and p.status.code == 0
end
s = input.harbor("live", auth=auth)
# footer
output(s)
