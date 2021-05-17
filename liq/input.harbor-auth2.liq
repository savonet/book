#!./liquidsoap
def auth(login)
  process.test("./harbor-auth \
    #{process.quote(login.user)} #{process.quote(login.password)}")
end
s = input.harbor("live", auth=auth)
output(s)
