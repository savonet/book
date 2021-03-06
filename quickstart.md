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

```{.liquidsoap}
output(sine())
```

which plays a sine wave at 440 Hertz. The operator `sine`{.liquidsoap}\indexop{sine} is called
a _source_\index{source}: it generates audio (here, a sine wave) and `output`{.liquidsoap}\indexop{output} is
an operator which takes a source as parameter and plays it on the
soundcard. When running this program, you should hear the expected well-known
sound and see lots of lines looking like this:

```
2021/02/18 15:20:44 >>> LOG START
2021/02/18 15:20:43 [main:3] Liquidsoap 2.0.0
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

```liquidsoap
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

In order to investigate further the possible variations on our example, let us
explore the parameters of the `sine` operator. In order to obtain
detailed help about this operator, we can type, in a console,

```
liquidsoap -h sine
```

which will output

```
Generate a sine wave.

Type: (?id : string, ?amplitude : float, ?float) -> source(audio=internal('a), video=internal('b), midi=internal('c))

Category: Source / Input

Parameters:

 * id : string (default: "")
     Force the value of the source ID.

 * amplitude : float (default: 1.0)
     Maximal value of the waveform.

 * (unlabeled) : float (default: 440.0)
     Frequency of the sine.
```

(this information is also present in [the online
documentation](https://www.liquidsoap.info/doc-dev/reference.html)).

It begins with a description of the operator, followed by its type\index{type}, category and
arguments\index{argument} (or parameters). There is also a section for methods, which is not shown above, but
we simply ignore it for now, it will be detailed in [a subsequent
section](#sec:records). Here, we see in the type that it is a function, because
of the presence of the arrow "`->`"\indexop{->}: the type of the arguments is indicated on
the left of the arrow and the type of the output is indicated on the right. More
precisely, we see that it takes three arguments and returns a source with any
number of audio, video and midi channels (the precise meaning of `source`
is detailed in [this section](#sec:source-type)). The three
arguments are indicated in the type and detailed in the following `Parameters` section:

- the first argument is a string labeled `id`: this is the name which will be
  displayed in the logs,
- the second is a float labeled `amplitude`: this controls how loud the
  generated sine wave will be,
- the third is a float with no label: the frequency of the sine wave.

All three arguments are optional, which means that a default value is provided
and will be used if it is not specified. This is indicated in the type by the
question mark "`?`" before each argument, and the default value is indicated in
`Parameters` (e.g. the default amplitude is `1.0` and the default frequency is
`440.` Hz).

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
parameters which can be discovered with `liquidsoap -h playlist`. For instance, by
default, the files are played in a random order, but if we want to play them as
indicated in the list we should pass the argument `mode="normal"`{.liquidsoap} to
`playlist`. Similarly, if we want to reload the playlist whenever it is changed,
the argument `reload_mode="watch"`{.liquidsoap} should be passed.

A playlist can refer to distant files (e.g. urls of the form
`http://path/to/file.mp3`) in which case they are going to be downloaded
beforehand. If you want to use a live stream, which can be very long or even infinite,
the operator `input.http` should be used instead:

```{.liquidsoap include="liq/input.http.liq" from=1}
```

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
section](#sec:clocks-ex). This will be detected by Liquidsoap an a script such
as

```liquidsoap
output(input.alsa())
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
`fallback`\indexop{fallback} operator which plays the first available source in a list of sources:

```{.liquidsoap include="liq/fallback.liq" from=1}
```

This means that `s` will have the same contents as `stream` if it is available,
and as `emergency` otherwise.

#### Fallibility detection

Liquidsoap automatically detects that a source is fallible and issues an error
if this is not handled, by a `fallback` for instance, in order to make sure that
we will not unexpectedly have nothing to stream at some point. We did not see
this up to now because `output` is an advanced operator which automatically uses
silence as fallback, because it is primarily intended for quick and dirty
checking of the stream.  However, if we use the primitive functions for
outputting audio, we will be able to observe this behavior. For instance, if we
try to use the operator `output.pulseaudio`, which plays a source on a soundcard
using the pulseaudio library,

```{.liquidsoap include="liq/bad/fallible1.liq" from=1}
```

we obtain the following error:

```
At line 1, char 4-27:
Error 7: Invalid value: That source is fallible
```

This means that Liquidsoap has detected that the source declared at line 1 from
character 4 to character 27, i.e. the `input.http`, is fallible. We could
simply ignore this warning, by passing the parameter `fallible=true`{.liquidsoap} to the
`output.pulseaudio`{.liquidsoap} operator, but the proper way to fix this consists in having
a fallback to a local file:

```{.liquidsoap include="liq/bad/fallible2.liq" from=1}
```

Note that we are using `single`\index{singleop} here instead of `playlist`: this operator plays
a single file and ensures that the file is available before running the script
so that we know it will not fail. The argument
`track_sensitive=false`{.liquidsoap}\index{track!sensitive} means that we want to get back to the live
stream as soon as it is available again, otherwise it would wait the end of the
track for switching back from emergency playlist to the main radio. Also remark
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

By default, the `switch` operator will wait for the end of the track of a source
before switching to the next one, but immediate switching can be achieved by
adding the argument `track_sensitive=false`{.liquidsoap}, as for the
`fallback` operator.

### Jingles

The next thing we want to be able to do is to insert jingles\index{jingle}. We suppose that we
have a playlist consisting of all the jingles of our radio and we want to play
roughly one jingle every 5 songs. This can be achieved by using the `random`\indexop{random}
operator:

```liquidsoap
jingles = playlist("/radio/jingles.pls")
radio   = random(weights=[1, 4], [jingles, radio])
```

This operator randomly selects a track in a list of sources each time a new
track has to be played (here this list contains the jingles playlist and the
radio defined above). The `weight` argument says how many tracks of each source
should be taken in average: here we want to take 1 jingle for 4 radio
tracks. The selection is randomized however and it might happen that two jingles
are played one after the other, although this should be rare. If we want to make
sure that we play 1 jingle and then exactly 4 radio songs, we should use the
`rotate`\indexop{rotate} operator instead:

```liquidsoap
radio = rotate(weights=[1, 4], [jingles, radio])
```

### Crossfading

\index{crossfading}

Now that we have our basic sound production setup, we should try to make things
sound nicer. A first thing we notice is that the transition between songs is
quite abrupt whereas we would rather have a smooth chaining between two
consecutive tracks. This can be addressed using the `crossfade`\indexop{crossfade} operator which
will take care of this for us. If we insert the following line

```liquidsoap
radio = crossfade(fade_out=3., fade_in=3., duration=5., radio)
```

at each end of track the song will fade out during 3 seconds, the next track
will fade in for 3 seconds and the two will overlap during 5 seconds, ensuring a
pleasant transition.

### Audio effects

In order to make the sound more uniform, we can use plugins. For instance, the
`normalize`\indexop{normalize} operator helps you to have a uniform volume by dynamically changing
it, so that volume difference between songs is barely heard:

```liquidsoap
radio = normalize(radio)
```

In practice, it is better to precompute the gain of each audio track in advance
and change the volume according to this information, often called _ReplayGain_\index{ReplayGain},
see [there](#sec:replaygain). There are also various traditional sound effects
that can be used in order to improve the overall color and personality of the
sound. A somewhat reasonable starting point is provided by the `nrj`\indexop{nrj} operator:

```liquidsoap
radio = nrj(radio)
```

Many more details about sound processing are given in
[there](#sec:signal-processing).

### Icecast output {#sec:icecast-setup}

Now that we have set up our radio, we could play it locally by adding

```liquidsoap
output(radio)
```

at the end of the script, but we would rather stream it to the world instead of
having it only on our speakers.

#### Installing Icecast

In order to do so, we first need to set up an Icecast\index{Icecast} server which will relay the
stream to users connecting to it. The way you should proceed with its
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
Once the configuration modified, you should the restart Icecast with the command

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

#### The encoder

The first argument `%mp3`, which controls the format, is called an _encoder_\index{encoder} and
can itself be passed some arguments in order to fine tune the encoding. For instance,
if we want our mp3 to have a 256k bitrate, we should pass
`%mp3(bitrate=256)`. It is perfectly possible to have multiple streams with
different formats for a single radio: if we want to also have an aac stream we
can add the line

```{.liquidsoap include="liq/output.icecast2.liq" from=2}
```

By the way, support for aac is not built in in the default installation. If you
get the message

```
Error 12: Unsupported format!
You must be missing an optional dependency.
```

this means that you did not enable it. In order to do so in an opam
installation, you should type

```
opam depext  fdkaac
opam install fdkaac
```

### Summing up

The typical radio script we arrived at is the following one:

```{.liquidsoap include="liq/radio.liq"}
```

That's it for now, we will provide many more details in [this
chapter](#chap:workflow).
