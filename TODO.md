- speak about %ifencoder and %else
- the `active_source` type should be removed (see #1671), rework the explanation
  of active sources
- from <https://github.com/savonet/liquidsoap/issues/1690>: the
  `set("decoder.debug",true)` is designed to let exceptions during decoding
  surface and crash the script so we can debug where they are coming from.
- `self_sync` for `input.ffmpeg`, see
  <https://github.com/savonet/liquidsoap/issues/1689>
- `clock_safe` vs `self_sync`, see
  <https://github.com/savonet/liquidsoap/issues/1687>
