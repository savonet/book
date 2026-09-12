s = playlist("~/Music")
s = rms(s)
current_rms = s.rms
s = lufs(s)
current_lufs = s.lufs
def metrics()
  {ready = s.is_ready(),
   rms   = dB_of_lin(current_rms()),
   lufs  = current_lufs()}
end
