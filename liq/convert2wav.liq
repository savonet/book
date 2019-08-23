#!/usr/bin/env -S liquidsoap -q

# Intput file name
infile = argv(1)

# Check that it exists
if infile == "" then
  print("Error: please provide a file as argument.")
  exit(1)
elsif not file.exists(infile) then
  print("Error: file #{infile} does not exist.")
  exit(1)
end

# Output file name
outfile = path.remove_extension(infile) ^ ".wav"

print(newline=false, "Encoding #{infile} to #{outfile}... ")

# Play the file once
s = once(single(infile))

# We use a clock with disabled synchronization
clock.assign_new(sync=false, [s])

# Function called at the end of encoding
def stop()
  print("done!")
  shutdown()
end

# Encode the file
output.file(%wav, outfile, fallible=true, on_stop=stop, s)
