def metadata.getter.float(init, metadata, s)
  x = ref(init)
  def f(m)
    s = m[metadata]
    if s != "" then x := float_of_string(s) end
  end
  s.on_metadata(f)
  {!x}
end
