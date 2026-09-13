#!/usr/bin/env liquidsoap
# header
settings.audio.converter.samplerate.converters :=
  ["libsamplerate", "ffmpeg", "native"]
