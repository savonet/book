s = https.get(
      "https://raw.github.com/savonet/liquidsoap/master/CHANGES.md")
print("Here are the latest changes in Liquidsoap:\n\n" ^ s)
