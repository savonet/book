#!./liquidsoap
radio = mksafe(playlist("~/Music"))
# header
output.icecast(%fdkaac, host="localhost", port=8000,
               password="hackme", mount="my-radio.aac", radio)
