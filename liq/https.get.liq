s = https.get("https://raw.githubusercontent.com/savonet/liquidsoap/master/CHANGES.md")
# s = https.get("https://git.io/JJ0Kk")
print("Here are the latest changes in Liquidsoap:\n" ^ s)
