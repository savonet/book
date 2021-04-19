#!./liquidsoap
def auth(login)
  ans = process.read.lines("./harbor-auth \
        #{string.quote(login.user)} #{string.quote(login.password)}")
  if list.hd(default="", ans) == "allowed" then
    true
  else
    log.important("Invalid login from #{login.user}")
    false
  end
end
s = input.harbor("live", port=8000, auth=auth)
output(s)
