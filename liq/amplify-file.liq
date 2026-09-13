#!./liquidsoap
s = playlist("~/Music")
# header
a = file.getter.float("volume")
s = amplify(a, s)
# footer
s = source.run(s, every=1., {print("amp: #{getter.get(a)}")})
output(s)
