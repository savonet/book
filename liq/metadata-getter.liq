def metadata.getter.float(initial, name, s)
  x = ref(initial)
  def f(m)
    v = m[name]
    if v != "" then x := float_of_string(v) end
  end
  s.on_metadata(synchronous=true, f)
  {x()}
end
