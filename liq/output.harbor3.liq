#!./liquidsoap
radio = mksafe(playlist("~/Music"))
def auth(~address, login, password)
  log.important("Authentication from #{login} / #{password}")
  string.length(password) mod 2 == 1
end
output.harbor(%mp3, auth=auth, mount="my-radio.mp3", radio)
