#!/usr/bin/env liquidsoap
def auth(username, password)
  ans = get_process_lines("./harbor-auth \
        #{string.quote(username)} #{string.quote(password)}")
  if list.hd(default="", ans) == "allowed" then
    true
  else
    log.important("Invalid login from #{username}")
    false
  end
end
s = input.harbor("live", port=8000, auth=auth)
output.pulseaudio(fallible=true, s)
