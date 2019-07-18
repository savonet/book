Full workflow of a radio station
================================

Playlists
---------

inotify

Interactive playlists
---------------------

Handling tracks
---------------

- crossfade
- blank detection
- log all the music files which have gone on air
- count the number of played music files (a reference!)

Cue points
----------

annotate, cue_in cue_out


Signal processing
-----------------

Good examples:

- https://savonet-users.narkive.com/MiNy36h8/have-a-sort-of-fm-sound-with-liquidsoap

Jingles
-------

Say the last song we had on air

Input streams with harbor
-------------------------

TODO: the `smooth_add` example from
<https://www.liquidsoap.info/doc-1.3.6/cookbook.html> to have the voice
over a bed

Monitoring the stream
---------------------

Use `on_blank` to detect blank...

Clocks: avoiding synchronization issues {#clocks}
---------------------------------------

Explain the problem with multiple icecast outputs.
