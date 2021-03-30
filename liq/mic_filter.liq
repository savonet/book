def mic_filter(s)
  filter(freq=200.,q=1.,mode="high",s)
end
