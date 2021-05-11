def metadata.getter.float(init, metadata, s)
  x = ref(init)
  def f(m)
    s = m[metadata]
    if s != "" then x := float_of_string(s) end
  end
  source.on_metadata(s, f)
  {!x}
end
