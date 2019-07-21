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
plays a sine wave at 440 Hertz. The operator^[TODO: terminologie : veut-on
"operator" ou "function" ?] `sine`{.liquidsoap} is called a _source_: it
generates audio (here, a sine wave) and `out`{.liquidsoap} is an operator which
takes a source as parameter and plays it on the sound card. When running this
program, you should hear the expected sound and see lots of lines looking like
this:

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
`add` is taking as argument a _list_ of sources, which could be of any size.

A radio
-------

### Playlists

```{.liquidsoap input="liq/playlist.liq"}
```






En gros reprendre le
[QUICKSTART](https://www.liquidsoap.info/doc-dev/quick_start.html).

Hello, world!
-------------

Our first program looks like this:
```
liquidsoap 'out(sine())'
```
We could have written it
```liquidsoap
#!/usr/bin/liquidsoap
out(sine())
```
or better, we give a name `s` to the source
```liquidsoap
#!/usr/bin/liquidsoap
# this is our source
s = sine()
out(s)
```

The path will be more like , use to know the path

Our first radio with a playlist
-------------------------------

EN GROS:
```liquidsoap
output.icecast(playlist("~/music/"))
```

Streams depending on the hour
-----------------------------

un switch
