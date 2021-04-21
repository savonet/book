#!./liquidsoap
s = https.get("https://raw.github.com/savonet/liquidsoap/master/CHANGES.md")
# s = http.get("http://www.google.fr/")
# print("Here are the latest changes in Liquidsoap:\n" ^ s)
print("Version: #{s.protocol_version}")
print("Code: #{s.status_code}")
print("Message: #{s.status_message}")
print("Headers: #{s.headers}")
