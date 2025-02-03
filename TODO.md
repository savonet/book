- liquidsoap-full is deprecated
- `self_sync` for `input.ffmpeg`, see
  <https://github.com/savonet/liquidsoap/issues/1689>
- `clock_safe` vs `self_sync`, see
  <https://github.com/savonet/liquidsoap/issues/1687>
- mentionner les autres images docker comme
  <https://github.com/PhasecoreX/docker-liquidsoap>
- les problèmes de seek FFmpeg devraient être ok
  <https://github.com/savonet/liquidsoap/issues/1706>
- smart crossfade is called `cross.smart`, see also `cross.simple`
- pour le multicore, FFmpeg fait ça bien:

  ```
  b = noise()
  clock.assign_new(sync='none',[b])
  output.file(%ffmpeg(%audio(codec="aac", b="128k"), %video(codec="libx264")), "/tmp/one.mp4", b)
  output.file(%ffmpeg(%audio(codec="aac", b="128k"), %video(codec="libx264")), "/tmp/two.mp4", b)
  ```

- les settings (#1722)
- `--conf-descr` renommé en `--list-settings`
- `dtmf.detect` dtmf detection
- playlists only have given number of requests in advance and not time anymore
  (#1791)
- mention `output.youtube.live`
- regexps #1881
- cons notation for lists
- interactive unit (#2075)
- patterns for records, etc.
- `output.harbor`
- video resizing, etc.

- progress bar on videos [#3149](https://github.com/savonet/liquidsoap/discussions/3149).
- script pour les covers [#3509](https://github.com/savonet/liquidsoap/discussions/3509)

- using chatGPT

From Changelog:
2.3.0:
Rewrote the streaming API to work with immutable frame content. 
Added script caching layer for faster script startup time.
Rewrote the clock/streaming loop layer.
Allow frames duration shorter than one video frames, typically values under 0.04s.
Change default frame duration to 0.02s
Added finally to execute code regardless of whether or not an exception is raised 
Removed taglib support. It is superseded by the internal ocaml-metadata module
Added video.canvas to make it possible to position video elements independently of the rendered video size
Added cover manager from an original code by @vitoyucepi (#3651)
Added let { foo? } = ... pattern matching 
Added support for sqlite databases
Added atomic file write operations.
Reimplemented request.once, single and more using source.dynamic. Removed experiment flag on source.dynamic.
Removed source.dump and source.drop in favor of safer request.dump and request.drop. 
Added support for parsing and rendering XML natively
Reimplemented audioscrobbler support natively using the more recent protocol
Reimplemented CUE file parser in native liquidsoap script, added support for multiple files and EAC non-compliant extension

2.2.0:
HLS: Added support for ID3 in-stream metadata (#3154) and custom tags 
Added support for YAML parsing and rendering
Added support for ffmpeg decoder parameters to allow decoding of raw PCM stream and file <- 👀
Added support for unit interactive variables: those call a handler when their value is set.
Added support for id3v2 v2.2.0 frames and pictures.
Added syntactic sugar for record spread: let {foo, gni, ..y} = x and y = { foo = 123, gni = "aabb", ...x}
References of type 'a are now objects of type (()->'a).{set : ('a) -> unit}
Switched to dune for building the binary and libraries.
Added support for a Javascript build an interpreter
Removed support for %define variables, superseded by support for actual variables in encoders.
Errors now report proper stack trace via their trace method, making it possible to programmatically point to file, line and character offsets of each step in the error call trace 
Removed confusing let json.stringify in favor of json.stringify().
cue_cut operator has been removed. Cueing mechanisms have been moved to underlying file-based sources. See migration notes for more details.
Added enable_autocue_metadata and autocue: protocol to automatically compute cue points and crossfade parameters


2.1.0:
Added support for variables in encoders
Added support for regular expressions
Added generalized support for value extraction patterns 
Rewrote our internal JSON parser/renderer
Removed support for partial application
Video images are now canvas
Images can now generate blank audio if needed, no need to add mux_audio(audio=blank(),image) anymore
