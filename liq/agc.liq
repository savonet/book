#!./liquidsoap
# header
pre    = lufs(playlist("~/Music"))
volume = ref(1.)
post   = lufs(amplify(volume, pre))
def adjust()
  gain = lin_of_dB((-14. - post.lufs_momentary()) / 20.)
  atomic({volume := max(0.01, min(10., volume() * gain))})
  print(newline=false,
    "LUFS: #{pre.lufs()} -> #{post.lufs()} (volume: #{volume()})\r")
end
thread.run(adjust, every=0.1)
output(post)
