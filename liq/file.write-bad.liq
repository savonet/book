#!./liquidsoap
data = "bla"
try
  file.write(data=data, "/non/existent/path")
catch err do
  log.important("Could not write to file: #{err.message}")
end
