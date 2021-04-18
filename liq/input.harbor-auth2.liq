#!./liquidsoap
def auth(~address, username, password)
  process.test("./harbor-auth \
    #{string.quote(username)} #{string.quote(password)}")
end
s = input.harbor("live", auth=auth)
output(s)
