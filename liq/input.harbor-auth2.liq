#!./liquidsoap
def auth(login)
  process.test("./harbor-auth \
    #{string.quote(login.user)} #{string.quote(login.password)}")
end
s = input.harbor("live", auth=auth)
output(s)
