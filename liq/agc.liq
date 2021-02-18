#!./liquidsoap
pre = playlist("~/Music")
pre = lufs(pre)
volume = ref(1.)
post = amplify({!volume}, pre)
post = lufs(post)
def adjust()
  v = lin_of_dB((-14. - post.lufs_momentary())/10.)
  volume := !volume * v
  volume := max(0., min(10., !volume))
  print(newline=false, "LUFS: #{pre.lufs()} -> #{post.lufs()} (volume: #{!volume})\r")
end
thread.run(adjust, delay=1., every=0.1)
output(post)
