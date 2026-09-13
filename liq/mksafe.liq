#!/usr/bin/env liquidsoap
# header
def mksafe(~id="mksafe", s) =
  fallback(
    id=id,
    [
      (s : source).{
        track_sensitive = false,
        on_select = source.composition.legacy_on_select
      },
      blank(id="safe_blank").{on_select = source.composition.legacy_on_select}
    ]
  )
end
