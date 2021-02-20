#!./liquidsoap
pre    = lufs(playlist("~/Music"))
volume = ref(1.)
post   = lufs(amplify({!volume}, pre))
def adjust()
  volume := !volume * lin_of_dB((-14. - post.lufs_momentary()) / 20.)
  volume := max(0.01, min(10., !volume))
  print(newline=false,
    "LUFS: #{pre.lufs()} -> #{post.lufs()} (volume: #{!volume})\r")
end
thread.run(adjust, every=0.1)
output(post)
