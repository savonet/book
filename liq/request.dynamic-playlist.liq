#!./liquidsoap
def playlist(~randomize=true, ~reload=true, p)
  l = ref(playlist.files(p))
  if randomize then l := list.shuffle(!l) end
  def next()
    if not (list.is_empty(!l)) then
      song = list.hd(!l)
      l := list.tl(!l)
      request.create(song)
    else
      if reload then l := playlist.files(p) end
      null()
    end
  end
  request.dynamic(next)
end
output(playlist("~/Music"))
