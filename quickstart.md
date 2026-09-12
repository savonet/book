Setting up a simple radio station {#chap:quickstart}
=================================

The sound of a sine wave {#sec:sound-sine}
------------------------

### Our first sound

In order to test your installation, you can try the following in a console:

```
liquidsoap 'output(sine())'
```

This instructs Liquidsoap to run the program

```{.liquidsoap include="liq/sine1.liq" from=2}
```

which plays a sine wave at 440 Hertz. The operator `sine`{.liquidsoap}\indexop{sine} is called
a _source_\index{source}: it generates audio (here, a sine wave) and `output`{.liquidsoap}\indexop{output} is
an operator which takes a source as parameter and plays it on the
soundcard. When running this program, you should hear the expected well-known
sound and see lots of lines looking like this:

```
2026/03/24 10:11:44 >>> LOG START
2026/03/24 10:11:32 [main:3] Liquidsoap 2.5.0
...
```

These are the _logs_\index{log} for Liquidsoap, which are messages describing what each
operator is doing. These are often useful to follow what the script is doing, and
contain important information in order to understand what is going wrong if it
is the case. Each of these lines begins with the date and the hour the message
was issued, followed by who emitted the message (i.e. which operator), its
importance, and the actual message. For instance, `[main:3]` means that the main
process of Liquidsoap emitted the message and that its importance is `3`. The
lower the number is, the more important the message is: `1` is a critical
message (the program might crash after that), `2` a severe message (something
that might affect the program in a deep way), `3` an important message, `4` an
information and `5` a debug message (which can generally be ignored). By
default, only messages with importance up to `3` are displayed.

### Scripts

You will soon find out that a typical radio takes more than one line of code, and it is
not practical to write everything on the command line. For this reason, the
code for describing your webradio can also be put in a _script_\index{script}, which is a file
containing all the code for your radio. For instance, for our sine example, we
can put the following code in a file `radio.liq`:

```{.liquidsoap include="liq/sine1.liq"}
```

The first line says that the script should be executed by Liquidsoap. It begins
by `#!` (sometimes called a _shebang_\index{shebang}) and then says that `/usr/bin/env` should be used in order to find the
path for the `liquidsoap` executable. If you know its complete path
(e.g. `/usr/bin/liquidsoap`) you could also directly put it:

```
#!/usr/bin/liquidsoap
```

In the rest of the book, we will generally omit this first line, since it is
always the same. The second line of `radio.liq`, is a comment\index{comment}. You can put
whatever you want here: as long as the line begins with `#`, it will not be taken
in account. The last line is the actual program we already saw above.

In order to execute the script, you should ensure that the program is executable
with the command

```
chmod +x radio.liq
```

and you can then run it with

```
./radio.liq
```

which should have the same effect as before. Alternatively, the script can also
be run by passing it as an argument to Liquidsoap

```
liquidsoap radio.liq
```

in which case the first line (starting with `#!`) is not required.

### Variables

In order to have more readable code, one can use variables\index{variable} which allow giving
names to sources. For instance, we can give the name `s` to our sine source and
then play it. The above code is thus equivalent to

```{.liquidsoap include="liq/sine2.liq" from=1}
```

### Parameters

Let us investigate further the possible variations on our example and
explore the parameters of the `sine` operator. In order to obtain
detailed help about this operator, we can type, in a console,

```
liquidsoap -h sine
```

which will output

```
Generate a sine wave.

Type: (?id : string?, ?amplitude : {float}, ?duration : float?, ?{float}) ->
source(audio=pcm*)

Category: Source / Input / Passive

Composition:

  This source uses file composition by default.

Arguments:

 * amplitude : {float} (default: 1.0)
     Maximal value of the waveform.

 * duration : float? (default: null)
     Duration in seconds (`null` means infinite).

 * id : string? (default: null)
     Force the value of the source ID.

 * (unlabeled) : {float} (default: 440.0)
     Frequency of the sine.
```

(this information is also present in [the online
documentation](https://www.liquidsoap.info/doc-dev/reference.html)).

It begins with a description of the operator, followed by its type\index{type}
and its category. The `Composition` section describes how `sine` behaves when
several sources take turns on the same stream. We come back to composition
below. Then come the arguments\index{argument} (or parameters). Three more
sections follow the ones printed above: `Methods`, `Callbacks` and `Composition
methods`. We simply ignore those three for now, as they will be detailed in [a
subsequent section](#sec:records). Here, we see in the type that `sine` is a
function, because of the presence of the arrow "`->`"\indexop{->}: the type of
the arguments is indicated on the left of the arrow and the type of the output is
indicated on the right. More precisely, we see that `sine` takes four arguments
and returns a source with an audio track made of any number of channels of raw
samples (the precise meaning of `source` is detailed in [this
section](#sec:source-type)). The four arguments are indicated in the type and
detailed in the following `Arguments` section, in alphabetical order:

- the argument labeled `id` is a string: this is the name which will be
  displayed in the logs,
- the argument labeled `amplitude` is a float: this controls how loud the
  generated sine wave will be,
- the argument labeled `duration` is a float too: the sine stops after that
  many seconds, and we leave `duration` out so that our sine plays forever,
- the last argument carries no label: this is the frequency of the sine wave.

All four arguments are optional, which means that a default value is provided
and will be used if it is not specified. This is indicated in the type by the
question mark "`?`" before each argument, and the default value is indicated in
`Arguments` (e.g. the default amplitude is `1.0` and the default frequency is
`440.` Hz). Incidentally, we could also have written `440` here: an integer is
accepted wherever a float is expected. Two more notations show up in this type.
A question mark *after* a type, as in `string?`, means that the value can also
be `null`. The default value of `id` and of `duration` is precisely `null`.
Braces around a type, as in `{float}`, mean that we can pass either a float or a
function computing one. Passing a function lets us change the frequency or the
amplitude while the stream is playing, see [there](#sec:getters).

If we want to generate a sine wave of 2600 Hz with an amplitude of 0.8, we can thus
write

```{.liquidsoap include="liq/sine3.liq" from=1}
```

Note that the parameter corresponding to id has a label `id`, which we have to
specify in order to pass the corresponding argument, and similarly for
amplitude, whereas there is no label for the frequency.

Finally, just for fun, we can hear an A minor chord by adding three sines:

```{.liquidsoap include="liq/sine4.liq" from=1}
```

We generate three sines at frequencies 440 Hz, 440×2^3/12^ Hz and
440×2^7/12^ Hz, adds them, and plays the result. The operator `add` is taking as
argument a _list_ of sources, delimited by square brackets, which could contain
any number of elements.

A radio {#sec:radio}
-------

### Playlists and more

Since we are likely to be here not to make synthesizers but rather radios, we should start playing actual music
instead of sines. In order to do so, we have the `playlist`\indexop{playlist} operator which takes
as argument a _playlist_: it can be a file containing paths to audio
files (wav, mp3, etc.), one per line, or a playlist in a standard format (pls,
m3u, xspf, etc.), or a directory (in which case the playlist consists of all the
files in the directory). For instance, if our music is stored in the `~/Music`
directory, we can play it with

```{.liquidsoap include="liq/playlist.liq" from=1}
```

As usual, the operator `playlist` has a number of interesting optional
parameters which can be discovered by typing `liquidsoap -h playlist`. For instance, by
default, `playlist` shuffles the files and plays them in that order until every
file has been played, and then shuffles them again. No song comes back before
all the others have been played. If we want to play the files in the order of
the list, we should pass the argument `mode="normal"`{.liquidsoap} to
`playlist`. If we would rather pick a file at random every time, and accept
repetitions, the argument is `mode="random"`{.liquidsoap}. Similarly, if we want
to reload the playlist whenever it is changed, the argument
`reload_mode="watch"`{.liquidsoap} should be passed.

A playlist can refer to distant files (e.g. urls of the form
`http://path/to/file.mp3`) in which case they are going to be downloaded
beforehand. If you want to use a live stream, which can be very long or even infinite,
the operator `input.http`\indexop{input.http} should be used instead:

```{.liquidsoap include="liq/input.http.liq" from=1}
```

`input.http` reads the stream with FFmpeg. The operator is therefore only
available if the `ffmpeg` package was installed alongside Liquidsoap, as
described in [the installation chapter](#chap:installation).

The playlist can also mention special sort of files, using particular
_protocols_\index{protocol} which are proper to Liquidsoap: those do not refer to actual files,
but rather describe how to produce files. For instance, a line of the form

```
say:Hello everybody!
```

in a playlist will instruct Liquidsoap to use a text-to-speech program in order
to generate a file in which "Hello everybody!" is pronounced.

Finally, there are other types of inputs. For instance, the operator
`input.alsa`\indexop{input.alsa} can be used to capture the sound of a microphone on a soundcard,
with the ALSA\index{ALSA} library. This means that you should be able to hear your voice with

```{.liquidsoap include="liq/mic.liq" from=1}
```

The ALSA input and the output each have their own way of synchronizing with
time: in our terminology, we say that they have different _clocks_, see [a later
section](#sec:clocks-ex). This will be detected by Liquidsoap and a script such
as

```{.liquidsoap include="liq/mic-no-buffer.liq" from=3}
```

will be rejected. This is the reason why we need to use the `buffer` operator
here which will compute part of the input stream in advance (1 second by
default) and will therefore be able to cope with small discrepancies in the way
the operators synchronize. If you try the above example, you can hear that there
is a slight delay between your voice and the output due to the buffering.

### Fallible sources and fallbacks {#sec:fallible}

Some sources are not always available, and we say that such a source is
_fallible_\index{fallibility}\index{source!fallible}. A typical example is a source obtained by `input.http`: at some
point the stream might stop (e.g. if it is only available during daytime), or be
subject to technical difficulties (e.g. it gets disconnected from the internet
for a short period of time). In this case, we generally want to fall back to
another source, typically an emergency playlist consisting of local files which
we are sure are going to be available. This can be achieved by using the
`fallback`\indexop{fallback} operator which plays the first source which is
ready to generate a stream in a list of sources:

```{.liquidsoap include="liq/fallback.liq" from=1}
```

This means that `s` will have the same contents as `stream` if it is available,
and as `emergency` otherwise.

#### Fallibility detection

Liquidsoap automatically detects that a source is fallible and issues an error
if this is not handled, by a `fallback` for instance, in order to make sure that
we will not unexpectedly have nothing to stream at some point. We did not see
this up to now because `output` is an operator primarily intended for quick and
dirty checking of the stream, and it therefore passes
`fallible=true`{.liquidsoap} for us. A fallible output stops while the source is
unavailable and starts again when the source is ready. `output` adds no sound of
its own. The operator which plays silence is `mksafe`{.liquidsoap}, presented
below. However, if we use the primitive functions for outputting audio, we will
be able to observe this behavior. For instance, if we
try to use the operator `output.pulseaudio`, which plays a source on a soundcard
using the pulseaudio library,

```{.liquidsoap include="liq/fallible1.liq" from=1}
```

we obtain the following error:

```
At fallible1.liq, line 2, char 4-28:
s = input.http("http://...")

Error 7: Invalid value:
That source is fallible.
This value was passed through the following call stack:
at fallible1.liq, line 3, char 0-20
```

The error names the file, the line and the characters of the faulty value,
prints that line, and then prints the call stack. The source declared at line 2
from character 4 to character 28, i.e. the `input.http`, is fallible. The
call stack tells us that this source was passed to `output.pulseaudio` at line
3. Keep in mind that line 1 is the shebang, which we no longer print. We could
simply ignore this error, by passing the parameter
`fallible=true`{.liquidsoap} to the `output.pulseaudio`{.liquidsoap} operator,
but the proper way to fix this consists in having a fallback to a local file:

```{.liquidsoap include="liq/fallible2.liq" from=1}
```

Note that we are using `single`\index{singleop} here instead of `playlist`: this operator plays
a single file and ensures that the file is available before running the script
so that we know it will not fail. We do not have to say anything about the
moment at which we get back to the live stream: a live source such as
`input.http` does not wait for the end of a track, so it takes over as soon
as it is available again, and each source decides this for itself, as
detailed in [there](#sec:composition). Also remark
that we are defining `s` twice: this is not a problem at all, whenever we
reference `s`, the last definition is used, otherwise said the second definition
replaces the first.

#### Falling back to blank

Another option to make the stream infallible would be to fall back to silence,
which in Liquidsoap can be generated with the operator `blank`\indexop{blank}:

```{.liquidsoap include="liq/fallible3.liq"}
```

This behavior is so common that Liquidsoap provides the `mksafe`\indexop{mksafe}
function which does exactly that:

```{.liquidsoap include="liq/fallible4.liq"}
```

### Streams depending on the hour

\index{predicate!time}\index{time!predicate}

A typical radio will do some scheduling, typically by having different playlists
at different times of the day. In Liquidsoap, this is achieved by using the
`switch`\indexop{switch} operator: this operator takes a list of pairs consisting of a
predicate (a function returning a boolean `true` or `false`) and a source, and
plays the first source for which the predicate is true. For time, there is a
special syntax:

```
{ 8h-20h }

```

is a predicate which is true when the current time is between 8h and 20h (or 8
am and 8 pm if you like this better). This means that if we have two playlists,
one for the day and one for the night, and want a live show between 19h and 20h,
we can set this up as follows:

```{.liquidsoap include="liq/radio.liq" from=2 to=5}
```

Every source has a `track_sensitive`{.liquidsoap}\index{track!sensitive}
method, and the `switch` operator reads it on both the source being played and
the source about to be played. When both are `true`, `switch` waits for the end
of the current track before switching. When one of them is `false`, `switch`
switches immediately. Liquidsoap sets `track_sensitive`{.liquidsoap} to `true`
on a source which plays files, such as our two playlists, and to `false` on a
live source, such as our microphone. At 19h the microphone is therefore
selected in the middle of the song being played, as we want from a live show,
and `switch` fades the interrupted song out over one second before the
microphone starts. We can set `track_sensitive`{.liquidsoap} ourselves on any
source, as for the `fallback` operator, and the whole mechanism is detailed in
[there](#sec:composition).

### Jingles

The next thing we want to be able to do is to insert jingles\index{jingle}. We suppose that we
have a playlist consisting of all the jingles of our radio and we want to play
roughly one jingle every 5 songs. This can be achieved by using the `random`\indexop{random}
operator:

```{.liquidsoap include="liq/radio-jingles.liq" from=2 to=-1}
```

The `random` operator selects a track at random in a list of sources each time a
new track has to be played (here this list contains the jingles playlist and the
radio defined above). The `weight`\index{weight} method of a source sets how
likely `random` is to pick that source, the default being 1: here the radio is
four times more likely than the jingles, so that we take roughly 1 jingle for 4
radio tracks. The selection is randomized however and it might happen
that two jingles are played one after the other, although this should be rare.
If we want to make sure that we play 1 jingle and then exactly 4 radio songs,
we should use the `rotate`\indexop{rotate} operator instead:

```{.liquidsoap include="liq/radio-rotate.liq" from=3 to=-1}
```

The `rotate` operator goes through the list in order. For `rotate`, `weight` is
the number of tracks played in a row from a source before moving to the next
source. By the way, `weight` also accepts a function, so we can change it while
the radio is running, for instance to play fewer jingles at night.

### Crossfading

\index{crossfading}

Now that we have our basic sound production setup, we should try to make things
sound nicer. A first thing we notice is that the transition between songs is
quite abrupt whereas we would rather have a smooth chaining between two
consecutive tracks. This can be addressed using the `crossfade`\indexop{crossfade} operator which
will take care of this for us. If we insert the following line

```{.liquidsoap include="liq/radio-crossfade.liq" from=2 to=-1}
```

at each end of track the song will fade out during 3 seconds, the next track
will fade in for 3 seconds and the two will overlap during 5 seconds, ensuring a
pleasant transition.

### Audio effects

In order to make the sound more uniform, we can use plugins. For instance, the
`normalize`\indexop{normalize} operator helps you to have a uniform volume by dynamically changing
it, so that volume difference between songs is barely heard:

```{.liquidsoap include="liq/radio-normalize.liq" from=2 to=-1}
```

In practice, it is better to precompute the gain of each audio track in advance
and change the volume according to this information, often called _ReplayGain_\index{ReplayGain},
see [there](#sec:replaygain). There are also various traditional sound effects
that can be used in order to improve the overall color and personality of the
sound. A somewhat reasonable starting point is provided by the `nrj`\indexop{nrj} operator:

```{.liquidsoap include="liq/radio-nrj.liq" from=2 to=-1}
```

`nrj` is one of the _extra_ operators, which come with the standard
installation. The `-minimal` binary packages described in [the installation
chapter](#chap:installation) leave the extra operators out, so `nrj` is missing
there.

Many more details about sound processing are given in
[there](#sec:signal-processing).

### Icecast output {#sec:icecast-setup}

Now that we have set up our radio, we could play it locally by adding

```{.liquidsoap include="liq/radio-output.liq" from=2}
```

at the end of the script, but we would rather stream it to the world instead of
having it only on our speakers.

#### Installing Icecast

In order to do so, we first need to set up an Icecast\index{Icecast} server which will relay the
stream to users connecting to it. Liquidsoap can be that server itself, with the
`icecast.server`\indexop{icecast.server} operator, see [there](#sec:outputs).
We use a separate Icecast server here, for the reasons given in
[there](#sec:audio-streaming). The way you should proceed with its
installation depends on your distribution, for instance on Ubuntu you can type

```
sudo apt install icecast2
```

The next thing we should do is to modify the configuration which is generally
located in the file `/etc/icecast2/icecast.xml`. In particular, we should
modify the lines

```
<source-password>hackme</source-password>
 <relay-password>hackme</relay-password>
 <admin-password>hackme</admin-password>
```

which are the passwords for sources (e.g. the one Liquidsoap is going to use in
order to send its stream to Icecast), for relays (used when relaying a stream, you
are not going to use this one now but still want to change the password) and for the
administrative interface. By default, all three are `hackme`, and we will use
that in our examples, but, again, you should change them in order not to be
hacked. Have a look at other parameters though, they are interesting too!
Once the configuration is modified, you should restart Icecast with the command

```
sudo /etc/init.d/icecast2 restart
```

If you are on a system such as Ubuntu, the default configuration prevents
Icecast from running, because they want to ensure that you have properly
configured it. In order to enable it, before restarting, you should set

```
ENABLE=true
```

at the end of the file `/etc/default/icecast2`. More information about setting
up Icecast can be found on [its website](http://www.icecast.org).

#### Icecast output

Once this is set up, you should add the following line to your script in
order to instruct Liquidsoap to send the stream to Icecast:

```{.liquidsoap include="liq/output.icecast.liq" from=2}
```

The parameters of the operator `output.icecast`\indexop{output.icecast} we used here are

- the format of the stream: here we encode as mp3,
- the parameters of your Icecast server: hostname, port (8000 is the default
  port) and password for sources,
- the mount point: this will determine the url of your stream,
- and finally, the source we want to send to Icecast, `radio` in our case.

If everything goes on well, you should be able to listen to your radio by
going to the url

```
http://localhost:8000/my-radio.mp3
```

with any modern player or browser. If you want to see the number of listeners of
your stream and other useful information, you should have a look at the stats of
Icecast, which are available at

```
http://localhost:8000/admin/stats.xsl
```

with the login for administrators (`admin` / `hackme` by default).

At some point you will want the radio to keep playing once you close your
terminal. Liquidsoap does not detach from the terminal. Use the service manager
of your system, `systemd`\index{systemd} on most Linux distributions and
`launchd`\index{launchd} on macOS. The service manager restarts the script if
the script dies, collects the logs, and runs the script as the user you
choose.

#### The encoder

The first argument `%mp3`, which controls the format, is called an _encoder_\index{encoder} and
can itself be passed some arguments in order to fine tune the encoding. For instance,
if we want our mp3 to have a 256k bitrate, we should pass
`%mp3(bitrate=256)`. It is perfectly possible to have multiple streams with
different formats for a single radio: if we want to also have an aac stream we
can add the line

```{.liquidsoap include="liq/output.icecast2.liq" from=2}
```

By the way, support for aac is not built into the default installation. If you
get the message

```
Error 12: Unsupported encoder: %fdkaac.
You must be missing an optional dependency.
```

this means that you did not enable it. In order to do so in an opam
installation, you should type

```
opam install fdkaac
```

### Summing up

The typical radio script we arrived at is the following one:

```{.liquidsoap include="liq/radio.liq"}
```

That's it for now, we will provide many more details in [this
chapter](#chap:workflow).
