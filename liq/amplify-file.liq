#!./liquidsoap
s = playlist("~/Music")
a = file.getter.float("volume")
s = amplify(a, s)
s = source.run(s, every=1., {print("amp: #{getter.get(a)}")}) output(s)
