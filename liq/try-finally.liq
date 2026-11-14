#!./liquidsoap
# header
def read_config() =
  try
    print("opening the configuration")
    error.raise(error.not_found, "no configuration")
  finally
    print("closing the configuration")
  end
end

try
  read_config()
catch err do
  print("could not read the configuration: #{err.message}")
end
