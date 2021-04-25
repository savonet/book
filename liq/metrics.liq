s = playlist("~/Music")
s = rms(s)
rms = s.rms
s = lufs(s)
lufs = s.lufs
def metrics()
  {ready = s.is_ready(),
   rms   = dB_of_lin(rms()),
   lufs  = lufs()}
end
