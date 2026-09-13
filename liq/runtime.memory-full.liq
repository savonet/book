#!./liquidsoap
# header
def log_memory()
  log.important(runtime.memory().pretty.process_physical_memory)
end
thread.run(every=60., log_memory)
output(blank())
