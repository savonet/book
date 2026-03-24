#!/usr/bin/env liquidsoap
autocue.register(name="my-autocue",
  fun (~request_metadata, ~file_metadata, fname) ->
    {
      cue_in     = 1.5,
      cue_out    = 178.3,
      fade_in    = 2.0,
      fade_out   = 3.0,
      start_next = 175.0
    }
  )
output(blank())