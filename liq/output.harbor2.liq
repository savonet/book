#!./liquidsoap
radio = mksafe(playlist("~/Music"))
# header
def auth({login, password})
  login == "bob" and password == "secret"
end
output.harbor(%mp3, auth=auth, mount="my-radio.mp3", radio)
