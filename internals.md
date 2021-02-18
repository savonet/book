Internals
=========

Overview
--------

After parsing a script, liquidsoap starts one or more streaming loop. Each streaming
loop is responsible for creating audio data from the inputs, pass it through the various
operators and, finally, send it to the outputs for instance to a icecast server, a sound
card etc. Each loop is attached to a **clock**, which is in charge of controlling the latency
during the streaming. For most cases, the clock follows the computer's CPU clock,
in order to stream data in real time to your listeners.

The elements that are filled during a clock cycle are called **frames**. They contain
the amount of data (audio, video) to be filled and sent to the outputs during each cycle. The 
frame size is calculated when starting liquidsoap and should be the smallest
size that can fit an interval of samples of each data type. Typically, a frame
for an audio rate of `44.1kHz` and video rate of `25Hz` fits `0.04s` of data. To
check this, look for the following lines in your liquidsoap logs:

```
[frame:3] Using 44100Hz audio, 25Hz video, 44100Hz master.
[frame:3] Frame size must be a multiple of 1764 ticks = 1764 audio samples = 1 video samples.
[frame:3] Targetting 'frame.duration': 0.04s = 1764 audio samples = 1764 ticks.
[frame:3] Frames last 0.04s = 1764 audio samples = 1 video samples = 1764 ticks.
```

The streaming algorithm works as follows: during one clock cycle, each output is 
given a frame to fill. In turn, the outputs pass their frame down to their connected
sources. For instance, if an output is connected to a `switch` operator, the
operator selects which source is  ready and, in turn, passes the frame to be filled
down to that source. All the data is filled in-place, to avoid data copy.

If a source is connected to multiple operators, it keeps a memoized
frame in order to generate its audio data only once during a single clock cycle,
sharing the result with all the operators it is connected to.

This operation goes on until the call returns. At this point, the frame is filled with
data and metadata. Most calls will fill up the entire frame at once. If the
frame is only partially filled after one call, we consider that the current
track has ended. This defines a track mark, used in many operators such as
`on_track`.

After one such filling loop, if the frame is partially filled and 
the source connected to the output is still available, another call
to to fill up the frame is issued, still within the same clock cycle.
When a source is considered `infallible`, we assume that this source will 
_always_ be able to fill up the current frame.

Once a frame is fully filled, the outputs proceed with the output procedure
they are designed to perform. For instance, a `output.icecast` encodes the data
and sends it to the connected icecast server.

## Clocks

As mentioned earlier, clocks control the latency associated with each streaming
cycle. The default clock tries to run this streaming loop in real-time,
speeding up when filling the frame takes more time than the frame's duration.
When this happens, you will see the infamous `catchup` log messaes:

```
[clock.wallclock_main:2] We must catchup 2.82 seconds!
```

However, in some cases such as a `input.alsa`, the sound card already has its own
clock. In this case, it is assumed that the source (or output) controls the latency,
blocking each filling call until it has enough data to return. For these situation,
the clock assigned by liquidsoap does _not_ try to control the latency and, instead,
runs the streaming loop as fast as possible, delegating latency control to the underlying
sources. In these situation, you will not see any `catchup` log messages.

There also are situations where the clock may switch from controlling the latency to delegating
it to the underlying sources or vice-versa. Consider for instance the following script:
```liquidsoap
s = fallback(track_sensitive=false,[
  input.harbor("foo"), input.alsa()
])
```
When `input.harbor` is available, the latency is controlled by liquidsoap however,
as soon as the `fallback` switches to `input.alsa`, latency is delegated to this source.
This can be seen in the logs as follows:
```
2019/12/14 15:20:39 [clock.main:3] Streaming loop starts in auto-sync mode
2019/12/14 15:20:39 [clock.main:3] Delegating synchronisation to CPU clock
...
2019/12/14 15:21:30 [clock.main:3] Delegating synchronisation to active sources
``` 

Clock cycles and frame duration define the I/O delay that you can expect when working
with liquidsoap. If you aim for a shorter delay, specially when working with only
audio, try to lower the video rate.\RB{Man we need to detect that and not use
video when computing the frame size!}. This also means that streaming happens by
increment of a frame's length. Thus, `source.time` for instance is precise down to
the frame's duration. The same goes for scripted fade operators. 

Implementation Overview
-----------------------

### Ticks

Ticks represent the internal sampling unit. They are defined as the smaller
sampling unit across all data types. For instance, wth `audio`
and `video` data, the sampling unit will be the audio sample rate,
since it is usually lower than the video sample rate.

### Frames

A frame is a triplet of arrays, each containing data for, respectively,
`audio`, `video` and `midi` content.

Audio content is represented by an array of `pcm` samples, encoded as
double precision floating point numbers. Video content is represented by
a triplet of arrays encoded in planar [YUV420](https://en.wikipedia.org/wiki/YUV#Y%E2%80%B2UV420p_(and_Y%E2%80%B2V12_or_YV12)_to_RGB888_conversion)
format.\RB{Sam, tu nous explique comment les données midi sont stockée?}

Sampling units are used to for position markers within the frame. Each
frame has two arrays of markers: an array of **breaks** and
an array of **metadata**.

Breaks are added each time the frame is filled. A break represent the last
position after a filling operation. Each filling operation is required to
add exactly one break.

In a typically execution, a filling operation with no track mark has only one
break, located right at the end of the frame. Otherwise, breaks located before the
frame's end represent markers for end of tracks.

Metadata are attached with their position within the frame and a list of pairs of
`(label, value)` metadata. Labels can be any string. However, metadata labels are filtered
before being exported, in order to prevent internal information leak. This is 
controlled by the `"encoder.encoder.export"` setting. 

### Seeking

Seeking is implement whenever possible. A `input.harbor` source, for instance, cannot
seek its data while a `playlist` source can. Also, seeking to the exact request position
might not be possible, instead seeking to a nearby position. For these reasons,
`source.seek` returns a floating point number. If this number is negative, seeking failed.
If this number is positive, it represents the position that was effectively seeked to.

Clocks & Time Discrepancies
---------------------------

Clocks in liquidsoap can be confusing. They are, however, central to the functioning of
the internals while streaming data. Let's try to explain why they had to be introducted
and how they are aasigned and used. For more details, the reader
is invited to checkout our initial research paper, entitled
[Liquidsoap: a High-Level Programming Language for Multimedia Streaming](https://www.liquidsoap.info/assets/docs/bbm10.pdf)

### What's the big deal?

To understand the need for clocks, we should first remember that all data in a digital
system is _sampled_. The sampling operation relies on a clock to tick at the frequency
that is used for sampling. For instance, for `44.1kHz` audio, the sampling operation relies
on a clock ticking every `1/44.100` seconds.

But, what happens if this clock, in fact, ticks at a slightly different rate, for instance 
`1/44.100+0.001` seconds? Even worst, and not to be pedantic here but, relativity theory actually tells us
that two clocks following different motions do not agree on time. A famous example being the fact
that the atomic clocks over the globe have to be mindful of their respective elevation, in order
to keep track of time discrepancies due to the earth's rotation..

But, anyways, let's go down to earth and consider a much more practical case: two computer's internal
clocks are _very_ likely to tick at slightly different rates. It can be that these two rates cancel out
statistically over time or, in the worst case, it can be that these two rates drift appart over time.

Consider now what happens when a listener receives a stream encoded by another computer. Locally, the listener
takes the sequence of data samples and re-assembles them to created an analog signal for human's consumption.
However, if the listener's and the encoder's clock do not agree, the might be some issues down the road.

When playing a recorded file, clock discrepancies between the encoder and decoder usually do not matter.
Eventually, for instance, a movie's playback time on the viewer's computer ends up being a slighly different
which does not really impact the viewer's experience. However, with a continuous, real-time stream, things
can be slightly more annoying. For instance, if the drift is constant over time, the listener's buffers might run out
of data or be overrun with data, leading to loss of data while playing the stream.

### How does it matter?

In liquidsoap, clock and time discrepancies matter on the following cases:

1. Reading or writing data to a sound card
2. Sending or receiving data over the network
3. Accelerating or slowing down a source's rate

The first case is the most straight forward: computer's sound card have their own
local clock, used for sampling and rendering audio data. This clock is different than
the computer's clock and, hopefully, more accurate. When accessing the sound card, either
to read (record) or write (play) data, the sound card's driver will block until enough 
data has been read or writen based on the sound card's clock. In such a case, liquidsoap
needs to be aware of the situation and delegate time synchronizatin to the sound card.

The second case is usually transient. Network operations can have slow down and blocking
if, for instance, the network is down. This can happen with `output.icecast`. Also, some
network operators such as `input.srt` have their own notion of time, similar to the sound
card's local clock, and will block to control the latency over which network data is being
delivered.

The third case is specific to our needs. Consider a source with track crossfades. Originally,
the source contains two track adjacent to each other: `<track1>, <track2>`. After applying a
crossdade, a portion of the ending and starting tracks overlap: 
`<track1 ...>, <end of track 1 + beginning of track 2>, <... track2>`\RB{Add figure}
After this operation, the stream's playback time is shortened by the amount of time used to
mix the two tracks.

In order to achieve this in a real-time stream, liquidsoap needs to briefly accelerate
the source in order to bufferize the beginning of `<track2>` and compute the crossfade transition.
This, in turn, requires that the source can actually be accelerated, which is possible if 
the source, for instance, is a playlist of files, but won't work if it is a live source from
the sound card. 

Lastly, there is still, of course, the chance that a listener's clock drifts
away from the clock used to synchronize liquidsoap. However, there isn't much that
we can do from a sender's perspective. In this case, we expect the listener's playback
software to be able to mitigate, for instance by using an adaptative resampler. One such
example is The VLC player.

Channels
--------

TODO: explain that channels are re-computed at wake up time, therefore we should
not for the evaluation of `self#ctype` before that (e.g. by initializing an
array with the number of channels)

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

Typing
------

TODO: explain more about typing

- subtyping (e.g. active sources <: sources)
- constraints (ordered, number, etc.)

Libraries around Liquidsoap
---------------------------

How to contribute
-----------------

### Getting stacktraces

```
% gdb -p <process PID>
> thread apply all bt
```
