Full workflow of a radio station
================================

Audio sources
-------------

### Playlists

A radio generally starts with a playlist, which is a list of files to play. The
`playlist` operator does that: it takes as argument either a playlist or a
directory (in which case the playlist will consist of all the files in the
directory). For instance,

```{.liquidsoap include="liq/playlist.liq" from=1}
```

The playlists generally contains one file per line, such as

```
/data/mp3/file1.mp3
/data/mp3/file2.mp3
/data/mp3/file3.mp3
http://server/file.mp3
ftp://otherserver/file.mp3
```

but other more advanced playlist formats are also supported: pls, m3u, asx,
smil, xspf, rss podcasts, etc. By default, the files are played in a random
order but this can be changed with the `mode` parameter of `playlist` which can
either be

- `"normal"`: play files in order,
- `"randomize"`: play files in a random order chosen for the whole playlist at
  each round (default mode),
- `"random"`: pick a random file each time in the playlist (there could thus be
  repetitions in files).
  
By default, the playlist is never reloaded, but this can be changed by using the
parameters `reload` and `reload_mode`, for instance:

- reload the playlist every hour (1 hour being 3600 seconds):
  
  ```liquidsoap
  s = playlist(reload=3600, reload_mode="seconds", "playlist")
  ```

- reload the playlist after each round (when the whole playlist has been played):

  ```liquidsoap
  s = playlist(reload=1, reload_mode="rounds", "playlist")
  ```
  
- reload the playlist whenever it changes (this requires Liquidsoap being
  compiled with support for the inotify library):

  ```liquidsoap
  s = playlist(reload_mode="watch", "playlist")
  ```

Another useful option is `check_next`, to specify a function which will
determine whether a file should be played or not in the playlist (this function
takes a request as argument and returns a boolean). For instance, we can ensure
that only the files whose name end in ".mp3" are played with

```{.liquidsoap include="liq/playlist-check.liq" from=1 to=-1}
```

If you only need to play one file, then you can avoid creating a playlist with
this file only, by using the operator `single` which loops on one file (it is
also more efficient in the case the file is distant because it is downloaded
once for all):

```liquidsoap
s = single("http://server/file.mp3")
```

By the way, if you do not want to loop over and over the file, and only play it
once, you can use the operator `once` which takes a source as argument and plays
one song of this source (it becomes unavailable after that).

```liquidsoap
s = once(single("http://server/file.mp3"))
```

### Protocols

We have seen that playlists can either contain files which are local or distant,
the latter beginning by


youtube-dl

the `say` protocol

```{.liquidsoap include="liq/say.liq" from=1 to=-1}
```

TODO: faire un exemple qui marche:

```{.liquidsoap include="liq/process.liq" from=1 to=-1}
```

`add_protocol`


- `process:<ext>,<cmd>:<input>` will launch `<cmd>` with `$(input)` replaced by
  the input `$(output)` by the output and `$(colon)` by `:`, to get a file

`prefix` parameter of `playlist`

### Distant streams

The operator for playlist makes sure in advance that the next file is available:
in particular, it downloads distant files so that they are ready when we need
them. 

- `input.http`
- `input.hls`

Liquidsoap can create a source that pulls its data from an HTTP location. This location can 
be a distant file or playlist, or an icecast or shoutcast stream.

To use it in your script, simply create a source that way:

```
# url is a HTTP location, like
# http://radiopi.org:8080/reggae
source = input.http(url)
```

This operator will pull regulary the given location for its data, so it should be used for 
locations that are assumed to be available most of the time. If not, it might generate unnecessary 
traffic and polute the logs. In this case, it is perhaps better to inverse the paradigm and 
use the [input.harbor](harbor.html) operator.

### Soundcard inputs

You can use [Liquidsoap](index.html) to capture and play through alsa with a minimal delay. This particulary useful when you want to run a live show from your computer. You can then directly capture and play audio through external speakers without delay for the DJ !

This configuration is not trivial since it relies on your hardware. Some hardware will allow both recording and playing at the same time, some only one at once, and some none at all.. Those note to configure are what works for us, we don't know if they'll fit all hardware.

First launch liquidsoap as a one line program

```
liquidsoap -v --debug 'input.alsa(bufferize=false)'
```

Unless you're lucky, the logs are full of lines like the following:

```

Could not set buffer size to 'frame.size' (1920 samples), got 2048.
```

The solution is then to fix the captured frame size to this value, which seems specific to your hardware. Let's try this script:

```
# Set correct frame size:
set("frame.audio.size",2048)

input = input.alsa(bufferize=false)
output.alsa(bufferize=false,input)
```

If everything goes right, you may hear on your output the captured sound without any delay ! If you want to test the difference, just run the same script with `bufferize=true` (or without this parameter since it is the default). The setting will be acknowledged in the log as follows:

```
Targetting 'frame.audio.size': 2048 audio samples = 2048 ticks.
```

If you experience problems it might be a good idea to double the value of the frame size. This increases stability, but also latency.

### Interactive playlists

TODO: an example of dynamic playlist generated by an external script, mention
sandboxing issues (see [later on](#sec:sandboxing)), `request.dynamic`

For instance, the following snippet defines a source which repeatedly plays the first valid URI in the playlist:

```liquidsoap
request.dynamic(
  { request.create("bar:foo",
      indicators=
        get_process_lines("cat "^quote("playlist.pls"))) })
```

Of course a more interesting behaviour is obtained with a more interesting program than cat.

another example in push mode with telnet.






### Harbor inputs

The operator input.harbor allows you to receive a source stream directly inside
a running Liquidsoap. It starts a listening server on where any
Icecast2-compatible source client can connect. When a source is connected, its
input if fed to the corresponding source in the script, which becomes
available. This can be very useful to relay a live stream without polling the
Icecast server for it. An example can be:

```liquidsoap
# Serveur settings
set("harbor.bind_addr","0.0.0.0")

# An emergency file
emergency = single("/path/to/emergency/single.ogg")

# A playlist
playlist = playlist("/path/to/playlist")

# A live source
live = input.harbor("live",port=8080,password="hackme")

# fallback
radio = fallback(track_sensitive=false,
                 [live,playlist,emergency])

# output it
output.icecast(%vorbis, radio,mount="test",host="host")
```

This script, when launched, will start a local server, here bound to
“0.0.0.0”. This means that it will listen on any IP address available on the
machine for a connection coming from any IP address. The server will wait for
any source stream on mount point “/live” to login. Then if you start a source
client and tell it to stream to your server, on port 8080, with password
“hackme”, the live source will become available and the radio will stream it
immediately.


Liquidsoap is also able to receive a source using icecast or shoutcast source protocol with 
the `input.harbor` operator. Using this operator, the running liquidsoap will open 
a network socket and wait for an incoming connection.

This operator is very useful to seamlessly add live streams
into your final streams:
you configure the live source client to connect directly to liquidsoap,
and manage the switch to and from the live inside your script.

Additionally, liquidsoap can handle many simulataneous harbor sources on different ports, 
with finer-grained authentication schemes that can be particularly useful when used with
source clients designed for the shoutcast servers.

SSL support in harbor can be enabled using of of the following `opam` packages: `ssl`, `osx-secure-transport`.
If enabled using `ssl`, `input.harbor.ssl` will be available. If enabled with `osx-secure-transport`, it will be
`input.harbor.secure_transport`.

#### Parameters
The global parameters for harbor can be retreived using
`liquidsoap --conf-descr-key harbor`. They are:

* `harbor.bind_addr`: IP address on which the HTTP stream receiver should listen. The default is `"0.0.0.0"`. You can use this parameter to restrict connections only to your LAN.
* `harbor.timeout`: Timeout for source connection, in seconds. Defaults to `30.`.
* `harbor.verbose`: Print password used by source clients in logs, for debugging purposes. Defaults to: `false`
* `harbor.reverse_dns`: Perform reverse DNS lookup to get the client's hostname from its IP. Defaults to: `true`
* `harbor.icy_formats`: Content-type (mime) of formats which allow shout (ICY) metadata update. Defaults to: ```
["audio/mpeg"; "audio/aacp"; "audio/aac"; "audio/x-aac"; "audio/wav"; "audio/wave"]```


If SSL support was enabled via `ssl`, you will have the following additional settings:

* `harbor.ssl.certificate`: Path to the SSL certificate.
* `harbor.ssl.private_key`: Path to the SSL private key (openssl only).
* `harbor.ssl.password`: Optional password to unlock the private key.

Obtaining a proper SSL certificate can be tricky. You may want to start with a self-signed certificate first.
You can obtain a free, valid certificate at: [https://letsencrypt.org/](https://letsencrypt.org/)

If SSL support is enable via `osx-secure-transport`, you will have the same settings but named: `harbor.secure_transport.*`.

To create a self-signed certificate for local testing you can use the following one-liner:

```
openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout server.key -out server.crt -subj "/CN=localhost" -days 3650
```

You also have per-source parameters. You can retreive them using the command 
`liquidsoap -h input.harbor`. The most important one are:

* `user`, `password`: set a permanent login and password for this harbor source.
* `auth`: Authenticate the user according to a specific function.
* `port`: Use a custom port for this input.
* `icy`: Enable ICY (shoutcast) source connections.
* `id`: The mountpoint registered for the source is also the id of the source.

When using different ports with different harbor inputs, mountpoints are attributed
per-port. Hence, there can be a harbor input with mountpoint `"foo"` on port `1356`
and a harbor input with mountpoint `"foo"` on port `3567`. Additionaly, if an harbor 
source uses custom port `n` with shoutcast (ICY) source protocol enabled, shoutcast
source clients should set their connection port to `n+1`.

The `auth` function is a function, that takes a pair `(user,password)` and returns a boolean representing whether the user 
should be granted access or not. Typical example can be:

```
def auth(user,password) = 
  # Call an external process to check 
  # the credentials:
  # The script will return the string 
  # "true" of "false"
  #
  # First call the script
  ret = get_process_lines("/path/to/script \
         --user=#{user} --password=#{password}")
  # Then get the first line of its output
  ret = list.hd(default="",ret)
  # Finally returns the boolean represented 
  # by the output (bool_of_string can also 
  # be used)
  if ret == "true" then
    true
  else
    false
  end
end
```

In the case of the `ICY` (shoutcast) source protocol, there is no `user` parameter 
for the source connection. Thus, the user used will be the `user` parameter passed 
to the `input.harbor` source.

When using a custom authentication function, in case of a `ICY` (shoutcast) connection, 
the function will receive this value for the username.

#### Usage
When using harbor inputs, you first set the required settings, as described above. Then, you define each source using `input.harbor("mountpoint")`. This source is faillible and will become available when a source client is connected. 

The unlabeled parameter is the mount point that the source client may connect
to. It should be `"/"` for shoutcast source clients.

The source client may use any of the recognized audio input codec. Hence, when using shoucast source clients, you need to have compiled liquidsoap with mp3 decoding support (`ocaml-mad`)

A sample code can be:

```
set("harbor.bind_addr","0.0.0.0")

# Some code...

# This defines a source waiting on mount point 
# /test-harbor
live = input.harbor("test-harbor",port=8080,password="xxx")

# This is the final stream.
# Uses the live source as soon as available,
# and don't wait for an end of track, since 
# we don't want to cut the beginning of the live
# stream.
#
# You may insert a jingle transition here...
radio = fallback(track_sensitive=false,
                 [live,files])
```




### Input streams with harbor

TODO: the `smooth_add` example from
<https://www.liquidsoap.info/doc-dev/cookbook.html> to have the voice over a
bed

Scheduling
----------

### Fallback

```liquidsoap
fallback([playlist("http://my/playlist"), single("/my/jingle.ogg")])
```

### Switching

```liquidsoap
# A scheduler, assuming you have defined the night and day sources
switch([ ({0h-7h}, night), ({7h-24h}, day) ])
```

explain `track_sensitive`

### Adding

`add` (example of a bed over a voice)

### Jingles

```liquidsoap
# Add a jingle to your normal source
# at the beginning of every hour:
add([normal,switch([({0m0s},jingle)])])
```

It can be useful to have a special playlist that is played at least every 20
minutes for instance (3 times per hour). You may think of a promotional playlist
for instance. Here is the recipe:

```liquidsoap
# (1200 sec = 20 min)
timed_promotions = delay(1200.,promotions)
main_source = fallback([timed_promotions,other_source])
```

Where promotions is a source selecting the file to be promoted.

### Live shows

Switch to a live show as soon as one is available. Make the show unavailable
when it is silent, and skip tracks from the normal source if they contain too
much silence.

```liquidsoap
stripped_stream = 
  strip_blank(input.http("http://myicecast:8080/live.ogg"))
fallback(track_sensitive=false,
         [stripped_stream,skip_blank(normal)])
```

Without the `track_sensitive=false` the fallback would wait the end of a track
to switch to the live. When using the blank detection operators, make sure to
fine-tune their threshold and length (float) parameters.

### Interactive values {#sec:telnet}

- switching with telnet (= switch on a boolean set via telnet)
- OSC (e.g. a switch, a volume)

There are two kinds of transitions. Transitions between two different children of a switch are not problematic. Transitions between different tracks of the same source are more tricky, since they involve a fast forward computation of the end of a track before feeding it to the transition function: such a thing is only possible when only one operator is using the source, otherwise it'll get out of sync.

##### Switch-based transitions
The switch-based operators (`switch`, `fallback` and `random`) support transitions. For every child, you can specify a transition function computing the output stream when moving from one child to another. This function is given two `source` parameters: the child which is about to be left, and the new selected child. The default transition is `fun (a,b) -> b`, it simply relays the new selected child source.

Transitions have limited duration, defined by the `transition_length` parameter. Transition duration can be overriden by passing a metadata. Default field for it is `"liq_transition_length"` but it can also be set to a different value via the `override` parameter. 

Here are some possible transition functions:

```
# A simple (long) cross-fade
# Use metadata override to make sure transition is long enough.
def crossfade(a,b)
  def add_transition_length(_) =
    [("liq_transition_length","15.")]
  end

  transition =
    add(normalize=false,
          [ sequence([ blank(duration=5.),
                       fade.in(duration=10.,b) ]),
            fade.out(duration=10.,a) ])

  # Transition can have multiple tracks so only pass the metadata
  # once.
  map_first_track(map_metadata(add_transition_length),transition)
end

# Partially apply next to give it a jingle source.
# It will fade out the old source, then play the jingle.
# At the same time it fades in the new source.
# Use metadata override to make sure transition is long enough.
def next(j,a,b)
  # This assumes that the jingle is 6 seconds long
  def add_transition_length(_) =
    [("liq_transition_length","15.")]
  end

  transition =
    add(normalize=false,
	  [ sequence(merge=true,
	             [ blank(duration=3.),
	               fade.in(duration=6.,b) ]),
	    sequence([fade.out(duration=9.,a),
	              j,blank()]) ])

  map_first_track(map_metadata(add_transition_length),transition)
end

# A transition, which does a cross-fading from A to B
# No need to override duration as default value (5 seconds)
# is over crossade duration (3 seconds)
def transition(j,a,b)
  add(normalize=false,
	  [ fade.in(duration=3.,b),
	    fade.out(duration=3.,a) ])
end
```

Finally, we build a source which plays a playlist, and switches to the live show as soon as it starts, using the `transition` function as a transition. At the end of the live, the playlist comes back with a cross-fading.

```
fallback(track_sensitive=false,
	     transitions=[ crossfade, transition(jingle) ],
	     [ input.http("http://localhost:8000/live.ogg"),
	       playlist("playlist.pls") ])
```

##### Cross-based transitions
The `cross()` operator allows arbitrary transitions between tracks of a same source. Here is how to use it in order to get a cross-fade:

```
def crossfade(~start_next,~fade_in,~fade_out,s)
  fade.in = fade.in(duration=fade_in)
  fade.out = fade.out(duration=fade_out)
  fader = fun (_,_,_,_,a,b) -> add(normalize=false,[fade.in(b),fade.out(a)])
  cross(duration=start_next,fader,s)
end
my_source =
  crossfade(start_next=1.,fade_out=1.,fade_in=1.,my_source)
```

The `crossfade()` function is already in liquidsoap. Unless you need a custom one, you should never have to copy the above example. It is implemented in the scripting language, much like this example. You can find its code in `utils.liq`.

The fade-in and fade-out parameters indicate the duraction of the fading effects. The start-next parameters tells how much overlap there will be between the two tracks. If you want a long cross-fading with a smaller overlap, you should use a sequence to stick some blank section before the beginning of `b` in `fader`.
The three parameters given here are only default values, and will be overriden by values coming from the metadata tags `liq_fade_in`, `liq_fade_out` and `liq_start_next`.

For an advanced crossfading function, you can see the [crossfade documentation](crossfade.html)


Handling tracks
---------------

### Metadata

- log all the music files which have gone on air
- count the number of played music files (a reference!)
- say the last song we had on air
- the annotate protocol

*ICY metadata* is the name for the mechanism used to update
metadata in icecast's source streams.
The techniques is primarily intended for data formats that do not support in-stream
metadata, such as mp3 or AAC. However, it appears that icecast also supports
ICY metadata update for ogg/vorbis streams.

When using the ICY metadata update mechanism, new metadata are submitted separately from
the stream's data, via a http GET request. The format of the request depends on the
protocol you are using (ICY for shoutcast and icecast 1 or HTTP for icecast 2).

Starting with 1.0, you can do several interesting things with icy metadata updates
in liquidsoap. We list some of those here.

You can enable or disable icy metadata update in `output.icecast`
by setting the `icy_metadata` parameter to either `"true"`
or `"false"`. The default value is `"guess"` and does the following:

* Set `"true"` for: mp3, aac, aac+, wav
* Set `"false"` for any format using the ogg container

You may, for instance, enable icy metadata update for ogg/vorbis
streams.

The function `icy.update_metadata` implements a manual metadata update
using the ICY mechanism. It can be used independently from the `icy_metadata`
parameter described above, provided icecast supports ICY metadata for the intended stream.

For instance the following script registers a telnet command name `metadata.update`
that can be used to manually update metadata:

```
def icy_update(v) =
  # Parse the argument
  l = string.split(separator=",",v)
  def split(l,v) =
    v = string.split(separator="=",v)
    if list.length(v) >= 2 then
      list.append(l,[(list.nth(v,0,default=""),list.nth(v,1,default=""))])
    else
      l
    end
  end
  meta = list.fold(split,[],l)

  # Update metadata
  icy.update_metadata(mount="/mystream",password="hackme",
                      host="myserver.net",meta)
  "Done !"
end

server.register("update",namespace="metadata",
                 description="Update metadata",
                 usage="update title=foo,album=bar,..",
                 icy_update)
```

As usual, `liquidsoap -h icy.update_metadata` lists all the arguments
of the function.


### Crossfading {#sec:crossfade}

crossfade
annotate, cue_in cue_out

Sources that support seeking can also be used to implement cue points.
The basic operator for this is `cue_cut`. Its has type:

```
(?id:string,?cue_in_metadata:string,
 ?cue_out_metadata:string,
 source(audio='#a,video='#b,midi='#c))->
    source(audio='#a,video='#b,midi='#c)
```

Its parameters are:

* `cue_in_metadata`: Metadata for cue in points, default: `"liq_cue_in"`.
* `cue_out_metadata`: Metadata for cue out points, default: `"liq_cue_out"`.
* The source to apply cue points to.

The values of cue-in and cue-out points are given in absolute
position through the source's metadata. For instance, the following
source will cue-in at 10 seconds and cue-out at 45 seconds on all its tracks:

```
s = playlist(prefix="annotate:liq_cue_in=\"10.\",liq_cue_out=\"45\":",
             "/path/to/music")

s = cue_cut(s)
```

As in the above example, you may use the `annotate` protocol to pass custom cue
points along with the files passed to Liquidsoap. This is particularly useful 
in combination with `request.dymanic` as an external script can build-up
the appropriate URI, including cue-points, based on information from your
own scheduling back-end.

Alternatively, you may use `map_metadata` to add those metadata. The operator
`map_metadata` supports seeking and passes it to its underlying source.


Signal processing
-----------------

### Normalization

normalization, replaygain (the protocol)

LADSPA plugins

Good examples:

- https://savonet-users.narkive.com/MiNy36h8/have-a-sort-of-fm-sound-with-liquidsoap

Outputs
-------

### Files

`output.file`, common encoding formats

It is sometimes useful (or even legally necessary) to keep a backup of an audio
stream. Storing all the stream in one file can be very impractical. In order to
save a file per hour in wav format, the following script can be used:

```
# A source to dump
# s = ...

# Dump the stream
file_name = '/archive/$(if $(title),"$(title)","Unknown archive")-%Y-%m-%d/%Y-%m-%d-%H_%M_%S.mp3'
output.file(%mp3,filename,s)
```

This will save your source into a `mp3` file with name specified by `file_name`.
In this example, we use [string interpolation](language.html) and time litterals to generate a different
file name each time new metadata are coming from `s`.


### Icecast

### HLS output

Monitoring the stream
---------------------

Use `on_blank` to detect blank...


On GeekRadio, we play many files, some of which include bonus tracks, which
means that they end with a very long blank and then a little extra music. It's
annoying to get that on air. The `skip_blank` operator skips the
current track when a too long blank is detected, which avoids that. The typical
usage is simple:

```liquidsoap
# Wrap it with a blank skipper
source = skip_blank(source)
```

At [RadioPi](http://www.radiopi.org/) they have another problem: sometimes they
have technical problems, and while they think they are doing a live show,
they're making noise only in the studio, while only blank is on air; sometimes,
the staff has so much fun (or is it something else ?) doing live shows that they
leave at the end of the show without thinking to turn off the live, and the
listeners get some silence again. To avoid that problem we made the
`strip_blank` operators which hides the stream when it's too blank
(i.e. declare it as unavailable), which perfectly suits the typical setup used
for live shows:

```liquidsoap
interlude = single("/path/to/sorryfortheblank.ogg")
# After 5 sec of blank the microphone stream is ignored,
# which causes the stream to fallback to interlude.
# As soon as noise comes back to the microphone the stream comes
# back to the live -- thanks to track_sensitive=false.
stream = fallback(track_sensitive=false,
	              [ strip_blank(max_blank=5.,live) , interlude ])

# Put that stream to a local file
output.file(%vorbis, "/tmp/hop.ogg", stream)
```

If you don't get the difference between these two operators, you should learn
more about liquidsoap's notion of [source](sources.html).

Finally, if you need to do some custom action when there's too much blank, we
have `on_blank`:

```liquidsoap
def handler()
  system("/path/to/your/script to do whatever you want")
end
source = on_blank(handler,source)
```




Clocks {#sec:clocks}
------

Explain the problem with multiple icecast outputs.

In the [quickstart](quick_start.html) and in the introduction to liquidsoap
[sources](sources.html), we have described a simple world in which sources
communicate with each other, creating and transforming data that
composes multimedia streams.
In this simple view, all sources produce data at the same rate,
animated by a single clock: at every cycle of the clock,
a fixed amount of data is produced.

While this simple picture is useful to get a fair idea of what's going on
in liquidsoap, the full picture is more complex: in fact, a streaming
system might involve *multiple clocks*, or in other words several
time flows.

It is only in very particular cases that liquidsoap scripts
need to mention clocks explicitly. Otherwise, you won't even notice
how many clocks are involved in your setup: indeed, liquidsoap can figure
out the clocks by itself, much like it infers types.
Nevertheless, there will sometimes be cases where your script cannot
be assigned clocks in a correct way, in which case liquidsoap will
complain. For that reason, every user should eventually get a minimum
understanding of clocks.

In the following, we first describe why we need clocks.
Then we go through the possible errors that any user might encounter
regarding clocks.
Finally, we describe how to explicitly use clocks,
and show a few striking examples of what can be achieved that way.

### Why multiple clocks

The first reason is **external** to liquidsoap: there is simply
not a unique notion of time in the real world.
Your computer has an internal clock which indicates
a slightly different time than your watch or another computer's clock.
Moreover, when communicating with a remote computer, network
latency causes extra time distortions.
Even within a single computer there are several clocks: notably, each
soundcard has its own clock, which will tick at a slightly different
rate than the main clock of the computer.
Since liquidsoap communicates with soundcards and remote computers,
it has to take those mismatches into account.

There are also some reasons that are purely **internal** to liquidsoap:
in order to produce a stream at a given speed,
a source might need to obtain data from another source at
a different rate. This is obvious for an operator that speeds up or
slows down audio (`stretch`). But it also holds more subtly
for `cross`, `cross` as well as the
derived operators: during the lapse of time where the operator combines
data from an end of track with the beginning of the other other,
the crossing operator needs twice as much stream data. After ten tracks,
with a crossing duration of six seconds, one more minute will have
passed for the source compared to the time of the crossing operator.

In order to avoid inconsistencies caused by time differences,
while maintaining a simple and efficient execution model for
its sources, liquidsoap works under the restriction that
one source belongs to a unique clock,
fixed once for all when the source is created.

The graph representation of streaming systems can be adapted
into a good representation of what clocks mean.
One simply needs to add boxes representing clocks:
a source can belong to only one box,
and all sources of a box produce streams at the same rate.
For example, 

```liquidsoap
output.icecast(fallback([crossfade(playlist(...)),jingles]))
```

yields the following graph:

![Graph representation with clocks](images/graph_clocks.png)

Here, clock_2 was created specifically for the crossfading
operator; the rate of that clock is controlled by that operator,
which can hence accelerate it around track changes without any
risk of inconsistency.
The other clock is simply a wallclock, so that the main stream
is produced following the ``real'' time rate.

### Error messages
Most of the time you won't have to do anything special about clocks:
operators that have special requirements regarding clocks will do
what's necessary themselves, and liquidsoap will check that everything is 
fine. But if the check fails, you'll need to understand the error,
which is what this section is for.

#### Disjoint clocks
On the following example, liquidsoap will issue the fatal error
`a source cannot belong to two clocks`:

```liquidsoap
s = playlist("~/media/audio")
output.alsa(s) # perhaps for monitoring
output.icecast(mount="radio.ogg",%vorbis,crossfade(s))
```

Here, the source `s` is first assigned the ALSA clock,
because it is tied to an ALSA output.
Then, we attempt to build a `crossfade` over `s`.
But this operator requires its source to belong to a dedicated
internal clock (because crossfading requires control over the flow
of the of the source, to accelerate it around track changes).
The error expresses this conflict:
`s` must belong at the same time to the ALSA clock
and `crossfade`'s clock.

##### Nested clocks
On the following example, liquidsoap will issue the fatal error
`cannot unify two nested clocks`:

```liquidsoap
jingles = playlist("jingles.lst")
music = rotate([1,10],[jingles,playlist("remote.lst")])
safe = rotate([1,10],[jingles,single("local.ogg")])
q = fallback([crossfade(music),safe])
```

Let's see what happened.
The `rotate` operator, like most operators, operates
within a single clock, which means that `jingles`
and our two `playlist` instances must belong to the same clock.
Similarly, `music` and `safe` must belong to that
same clock.
When we applied crossfading to `music`,
the `crossfade` operator created its own internal clock,
call it `cross_clock`,
to signify that it needs the ability to accelerate at will the
streaming of `music`.
So, `music` is attached to `cross_clock`,
and all sources built above come along.
Finally, we build the fallback, which requires that all of its
sources belong to the same clock.
In other words, `crossfade(music)` must belong
to `cross_clock` just like `safe`.
The error message simply says that this is forbidden: the internal
clock of our crossfade cannot be its external clock -- otherwise
it would not have exclusive control over its internal flow of time.

The same error also occurs on `add([crossfade(s),s])`,
the simplest example of conflicting time flows, described above.
However, you won't find yourself writing this obviously problematic
piece of code. On the other hand, one would sometimes like to
write things like our first example.

The key to the error with our first example is that the same
`jingles` source is used in combination with `music`
and `safe`. As a result, liquidsoap sees a potentially
nasty situation, which indeed could be turned into a real mess
by adding just a little more complexity. To obtain the desired effect
without requiring illegal clock assignments, it suffices to
create two jingle sources, one for each clock:

```liquidsoap
music = rotate([1,10],[playlist("jingles.lst"),
                       playlist("remote.lst")])
safe  = rotate([1,10],[playlist("jingles.lst"),
                       single("local.ogg")])
q = fallback([crossfade(music),safe])
```

There is no problem anymore: `music` belongs to 
`crossfade`'s internal clock, and `crossfade(music)`,
`safe` and the `fallback` belong to another clock.

#### The clock API
There are only a couple of operations dealing explicitly with clocks.

The function `clock.assign_new(l)` creates a new clock
and assigns it to all sources from the list `l`.
For convenience, we also provide a wrapper, `clock(s)`
which does the same with a single source instead of a list,
and returns that source.
With both functions, the new clock will follow (the computer's idea of)
real time, unless `sync=false` is passed, in which case
it will run as fast as possible.

The old (pre-1.0.0) setting `root.sync` is superseded
by `clock.assign_new()`.
If you want to run an output as fast as your CPU allows,
just attach it to a new clock without synchronization:

```liquidsoap
clock.assign_new(sync=false,[output.file(%vorbis,"audio.ogg",source)])
```

This will automatically attach the appropriate sources to that clock.
However, you may need to do it for other operators if they are totally
unrelated to the first one.

\TODO{mention the `buffer.adaptative` operator}
The `buffer()` operator can be used to communicate between
any two clocks: it takes a source in one clock and builds a source
in another. The trick is that it uses a buffer: if one clock
happens to run too fast or too slow, the buffer may empty or overflow.

Finally, `get_clock_status` provides information on
existing clocks and track their respective times:
it returns a list containing for each clock a pair
`(name,time)` indicating
the clock id its current time in *clock cycles* --
a cycle corresponds to the duration of a frame,
which is given in ticks, displayed on startup in the logs.
The helper function `log_clocks` built
around `get_clock_status` can be used to directly
obtain a simple log file, suitable for graphing with gnuplot.
Those functions are useful to debug latency issues.

### External clocks: decoupling latencies
The first reason to explicitly assign clocks is to precisely handle
the various latencies that might occur in your setup.

Most input/output operators (ALSA, AO, Jack, OSS, etc)
require their own clocks. Indeed, their processing rate is constrained
by external sound APIs or by the hardware itself.
Sometimes, it is too much of an inconvenience,
in which case one can set `clock_safe=false` to allow
another clock assignment --
use at your own risk, as this might create bad latency interferences.

Currently, `output.icecast` does not require to belong
to any particular clock. This allows to stream according to the
soundcard's internal clock, like in most other tools:
in

```liquidsoap
output.icecast(%vorbis,mount="live.ogg",input.alsa())
```
,
the ALSA clock will drive the streaming of the soundcard input via
icecast.

Sometimes, the external factors tied to Icecast output cannot be
disregarded: the network may lag. If you stream a soundcard input
to Icecast and the network lags, there will be a glitch in the
soundcard input -- a long enough lag will cause a disconnection.
This might be undesirable, and is certainly disappointing if you
are recording a backup of your precious soundcard input using
`output.file`: by default it will suffer the same
latencies and glitches, while in theory it could be perfect.
To fix this you can explicitly separate Icecast (high latency,
low quality acceptable) from the backup and soundcard input (low latency,
high quality wanted):

```liquidsoap
input = input.oss()

clock.assign_new(id="icecast",
  [output.icecast(%mp3,mount="blah",mksafe(buffer(input)))])

output.file(
  %mp3,"record-%Y-%m-%d-%H-%M-%S.mp3",
  input)
```

Here, the soundcard input and file output end up in the OSS
clock. The icecast output
goes to the explicitly created `"icecast"` clock,
and a buffer is used to
connect it to the soundcard input. Small network lags will be
absorbed by the buffer. Important lags and possible disconnections
will result in an overflow of the buffer.
In any case, the OSS input and file output won't be affected
by those latencies, and the recording should be perfect.
The Icecast quality is also better with that setup,
since small lags are absorbed by the buffer and do not create
a glitch in the OSS capture, so that Icecast listeners won't
notice the lag at all.

### Internal clocks: exploiting multiple cores
Clocks can also be useful even when external factors are not an issue.
Indeed, several clocks run in several threads, which creates an opportunity
to exploit multiple CPU cores.
The story is a bit complex because OCaml has some limitations on
exploiting multiple cores, but in many situations most of the computing
is done in C code (typically decoding and encoding) so it parallelizes
quite well.

Typically, if you run several outputs that do not share much (any) code,
you can put each of them in a separate clock.
For example the following script takes one file and encodes it as MP3
twice. You should run it as `liquidsoap EXPR -- FILE`
and observe that it fully exploits two cores:

```liquidsoap
def one()
  clock.assign_new(sync=false,
        [output.file(%mp3,"/dev/null",single(argv(1)))])
end
one()
one()
```

TODO: explain the operators who need to be clocked for instance, we had the
following question: Yamakaky [5:20 PM] Does `input.harbor` require the use of
`clock` and `buffer`? It has an internal buffer so I would say no?
