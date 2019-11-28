Internals
=========

The OCaml language
------------------

A good book to get started: [@realworldocaml]

The stream model
----------------

### Frames

### Ticks

### Track boundaries

En gros, chaque appel a `get_frame` doit ajouter exactement un break. Si le
break est en fin de frame, on a fini sinon c'est une fin de piste.

### Metadata

The source model
----------------

Once a script has been parsed and compiled, liquidsoap will start the streaming
loop. The loop is animated from the outputs: for each clock, during one clock
cycle the streaming loop queries each output connected to that clock. These
outputs are given a frame to fill up, which contains all the data (audio, video,
midi) that will be produced during that clock cycle.

The frame size is calculated when starting liquidsoap and should be the smallest
size that can fit an interval of samples of each data type. Typically, a frame
for a audio rate of `44.1kHz` and video rate of `25Hz` fits `0.04s` of data. To
check this, look for the following lines in your liquidsoap logs:

```
[frame:3] Using 44100Hz audio, 25Hz video, 44100Hz master.
[frame:3] Frame size must be a multiple of 1764 ticks = 1764 audio samples = 1 video samples.
[frame:3] Targetting 'frame.duration': 0.04s = 1764 audio samples = 1764 ticks.
[frame:3] Frames last 0.04s = 1764 audio samples = 1 video samples = 1764 ticks.
```

During one clock cycle, each output is given one such frame to fill. All the
data is filled in-place, which avoids data copy as much as possible. When asked
to fill up a frame, each output passes its frame down to its connected
source. Then, for instance if the output is a `switch` operator, the operator
selects which source is ready and, in turn, passes the frame to be down to that
source. If a source is connected to multiple operators, it keeps a memoized
frame so that it does the computation required once during a single clock cycle,
sharing the result with all the operators it is connected to.

This goes on until the call returns. At this point, the frame is filled up with
data and metadata. Most calls will fill up the entire frame at once. If the
frame is only partially filled after one call, we consider that the current
track has ended. This defines a track mark, used in many operators such as
`on_track`. Then, if the source connected to the output is still available,
another call to fill up the frame is issued, still within the same clock
cycle. Otherwise, the output ends.

When a source is considered `infallible`, we assume that this source will
_always_ be able to fill up the current frame.

The runtime loop is important to keep in mind when trying to understand how
liquidsoap works. Clocks are at the core of it.  A normal clock will try to run
this streaming loop in real-time, speeding up when filling the frame takes more
time than the frame's length, which is when the infamous `catchup` log messages
will come up:

```
[clock.wallclock_main:2] We must catchup 2.82 seconds!
```

Furthermore, it is important to keep in mind that streaming happens by increment
of a frame's length. Typically, `source.time` is precise down to a frame
duration. This is also defines the I/O delay that you can expect when working
with liquidsoap. If you aim for a shorter one, specially when working with only
audio, try to lower the video rate.\RB{Man we need to detect that and not use
video when computing the frame size!}


TODO: get_ready, etc.

### Clocks

[See here](https://github.com/savonet/liquidsoap/issues/288)

### Seeking

### Active / passive sources

what are those???

Requests
--------

The purpose of a request is to get a valid file. The file can contain media in
which case validity implies finding a working decoder, or can be something
arbitrary, like a playlist. This file is fetched using protocols. For example
the fetching can involve querying a mysql database, receiving a list of new
URIS, using http to download the first URI, check it, fail, using smb to
download the second, success, have the file played, finish the request, erase
the temporary downloaded file. This process involve a tree of URIs, represented
by a list of lists.  Metadata is attached to every file in the tree, and the
view of the metadata from outside is the merging of all the metadata on the path
from the current active URI to the root.  At the end of the previous example,
the tree looks like:

```
[ [ "/tmp/localfile_from_smb" ] ;
  [
    (* Some http://something was there but was removed without producing
     * anything. *)
    "smb://something" ; (* The successfully downloaded URI *)
    "ftp://another/uri" ;
    (* maybe some more URIs are here, ready in case of more failures *)
  ] ;
  [ "mydb://myrequest" ] (* And this is the initial URI *)
]
```


Libraries around Liquidsoap
---------------------------

How to contribute
-----------------

### Getting stacktraces

```
% gdb -p <process PID>
> thread apply all bt
```
