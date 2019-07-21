Setting up a simple radio station
=================================

The sound of a sine wave
------------------------

### A first sound

In order to test your installation, you can try the following in a console:

```
liquidsoap 'out(sine())'
```

This instructs Liquidsoap to run the program `out(sine())`{.liquidsoap} which
plays a sine wave at 440 Hertz. The operator `sine`{.liquidsoap} is called a
_source_: it generates audio (here, a sine wave) and `out`{.liquidsoap} is an
operator which takes a source as parameter and plays it on the sound card. When
running this program, you should hear the expected sound and see lots of lines
looking like this:

```
2019/07/21 00:12:31 >>> LOG START
2019/07/21 00:12:31 [main:3] Liquidsoap 1.4.0
...
```

These are the _logs_ for Liquidsoap, which are messages describing what each
operator is doing. These are often useful to follow what the script is doing and
contain important information in order to understand what is going wrong if it
is the case. Each of these lines begin with the date and the hour the message
was issued, followed by who emitted the message, its importance, and the actual
message. For instance, `[main:3]` means that the main process of Liquidsoap
emitted the message and that its importance is `3`. The lower the number is, the
more important the message is: `1` is a critical message (the program might
crash after that), `2` a severe message (something that might affect the program
in a deep way), `3` an important message, `4` an information and `5` a debug
message (which can generally be ignored).

### Scripts

You will soon find out that a typical radio takes a few lines of code, and it is
not practical to write them directly in the command line. For this reason, the
code for describing your webradio can also be put in a _script_, which is a file
containing all the code for your radio. For instance, for our sine example, you
can put the following code in a file `radio.liq`:

```{.liquidsoap include="liq/sine1.liq"}
```

The first line says that the script should be executed by Liquidsoap. It should
always start by `#!` followed by the path to the Liquidsoap binary, which is
generally `/usr/bin/liquidsoap` but might differ on your computer, for instance
if you installed using opam: in order to know the path to the binary, you can type

```
which liquidsoap
```

In the rest of the book, we will generally omit this line, since it is always
the same. The second line, is a comment: you can put whatever you want here as
long as the line begins with `#`, it will not be taken in account. The last line
is the actual program we already saw above. In order to execute the script, you
should ensure that the program is executable with the command

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

In order to have more readable code, one can use variables which allow giving
names to sources. For instance, we can give the name `s` to our sine source and
then play it. The above code is thus equivalent to

```{.liquidsoap include="liq/sine2.liq"}
```

### Parameters

In order to investigate further the possible variations on our example, let us
investigate all the parameters of the `sine` operator. In order to obtained
detailed help about this operator, type in a console

```
liquidsoap -h 
```

(you can also have this information in [the online
documentation](https://www.liquidsoap.info/doc-dev/reference.html)), which will
output

```
Generate a sine wave.

Type: (?id : string, ?amplitude : float, ?float) -> source(audio='#a+1, video=0, midi=0)

Category: Source / Input

Parameters:

 * id : string (default: "")
     Force the value of the source ID.

 * amplitude : float (default: 1.0)
     Maximal value of the waveform.

 * (unlabeled) : float (default: 440.0)
     Frequency of the sine.
```

It begins with a description of the operator, followed by its type, category and
parameters. Here, the type indicates that it is a function taking three
arguments and returning a source with at least one audio channel and no audio or
midi channel. The three arguments are indicated in the type and detailed after:

- the first argument is a string labeled `id`: this is the name which will be
  displayed in the logs,
- the second is a float labeled `amplitude`: this controls how loud the
  generated sine wave will be,
- the third is a float with no label: the frequency of the sine wave.

All three arguments are optional, which means that a default value is provided
and will be used if it is not specified. This is indicated in the type by the
question mark before each argument, and the default value is detailed below
(e.g. the default amplitude is `1.0` and the default frequency is `440.` Hertz).

If we want generate a sine wave of 2600 Hz with an amplitude 0.8, we can thus do

```{.liquidsoap include="liq/sine3.liq"}
```

Note that the parameter corresponding to id has a label `id`, which we have to
specify in order to pass the corresponding argument, and similarly for
amplitude, whereas there is no label for the frequency.

Finally, just for fun, we can hear an A minor chord by adding three sines:

```{.liquidsoap include="liq/sine4.liq"}
```

We generates three sines at frequencies $440$ Hz, $440\times 2^{3/12}$ Hz and
$440\times 2^{7/12}$ Hz, add them, and play the result. Note that the operator
`add` is taking as argument a _list_ of sources (delimited by square brackets),
which could be of any size.

A radio
-------

### Playlists

Since we are not here to make synthesizers, we should start playing actual music
instead of sines. In order to do so, we have the `playlist` operator which takes
as argument a _playlist_: this playlist can be a file containing paths to audio
files (wav, mp3, etc.), one per line, or a playlist in a standard format (pls,
m3u, xspf, etc.), or a directory (in which case the playlist consists of all the
files in the directory). For instance, if our music is stored in the `~/Music`
directory, we can play it with

```{.liquidsoap include="liq/playlist.liq"}
```

As usual, the operator `playlist` has a number of interesting optional
parameters which can be obtained with `liquidsoap -h playlist`. For instance, by
default the files are played in a random order, but if we want to play them as
indicated we should pass the argument `mode="normal"`{.liquidsoap} to
`playlist`. Similarly, if we want to reload the playlist whenever it is changed,
the argument `reload_mode="watch"`{.liquidsoap} should be passed.

A playlist can contain distant files (e.g. urls of the form
`http://.../file.mp3`) in which case they are going to be downloaded
beforehand. If you want to use a live stream, the operator `input.http` should
be used instead:

```{.liquidsoap include="liq/input.http.liq"}
```

### Fallbacks

A source can be not always available, we call this a _fallible_ source. A
typical example, is a source obtained by `input.http`: at some point the stream
might stop (e.g. if it is only available during daytime), or be subject to
technical difficulties (e.g. it gets disconnected from the internet for a short
period of time). In this case, we generally want to fallback to another source
(typically an emergency playlist consisting of local files which we are sure are
going to be available). This can be achieved by using the `fallback` operator
which plays the first source available in a list of sources:

```{.liquidsoap include="liq/fallback.liq"}
```

In fact, Liquidsoap automatically detects that a source is fallible and issues
an error if this is not handled (typically by a `fallback`). We did not see this
up to now because `out` is an advanced operator which automatically uses silence
as fallback. However, if we use the primitive functions for outputting audio, we
will see this behavior. For instance, if we try use the operator
`output.pulseaudio` (which plays a source on a soundcard using the pulseaudio
library)

```{.liquidsoap include="liq/fallible1.liq"}
```

we obtain the following error:

```
At line 1, char 5-27:
Error 7: Invalid value:
That source is fallible
```

.......................................

### Streams depending on the hour

### Icecast output




En gros reprendre le
[QUICKSTART](https://www.liquidsoap.info/doc-dev/quick_start.html).
