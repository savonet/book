#!./liquidsoap
set("sandbox", true)
def auth(login)
  p = process.run(rodirs=["/users"], rwdirs=[], network=false,
        "./harbor-auth \
        #{string.quote(login.user)} #{string.quote(login.password)}")
  p.status == "exit" and p.status.code == 0
end
s = input.harbor("live", auth=auth)
output(s)
