Installation {#chap:installation}
============

In order to install Liquidsoap you should either download compiled binaries for
your environment, or compile it by yourself. The latest is slightly more
involved (although it is now a mostly automated process), but allows you to
easily obtain a cutting-edge version and take part of the development
process. These instructions are for the latest released version at the time of
the writing, you are encouraged to consult the online documentation 


Automated building using Opam
-----------------------------

The recommended method to install Liquidsoap is by using the [package manager
opam](http://opam.ocaml.org/). This program, which is available on all major
distributions and architectures, makes it easy to build programs written in
OCaml by installing the required dependencies (the libraries the program needs
to be compiled) and managing consistency between various versions. The opam
packages for Liquidsoap and associated libraries are actively maintained in
opam.

### Installing opam

The easiest way to install opam on any achitecture is by running the command

```
sh <(curl -sL https://git.io/fjMth)
```

or by installing the `opam` package with the package manager of your
distribution, e.g., for Ubuntu,

```
sudo apt-get install opam
```

or by downloading the binaries from [the opam
website](https://opam.ocaml.org/doc/Install.html). In any case, ensure that you
have at least the version 2.0.0 of opam (this version can be obtained by `opam
--version`).

If you are installing opam for the first time, you should initialize the list of
opam packages

```
opam init
```

and install a recent version of the ocaml compiler

```
opam switch create 4.08.0
```

### Installing Liquidsoap

Once this is done, a typical installation of Liquidsoap with support for mp3
encoding/decoding and icecast is done by executing:

```
opam depext taglib mad lame cry samplerate liquidsoap
opam install taglib mad lame cry samplerate liquidsoap
```

The first line (`opam depext ...`) takes care of installing the required
external dependencies, i.e., the libraries we are relying on, but did not
develop by ourselves. Here, we want to install the dependencies required by
`taglib` (the library to read tags in audio files), `mad` (to decode mp3),
`lame` (to encode mp3), `cry` (to stream to icecast), `samplerate` (to resample
audio) and finally `liquidsoap`. The second line (`opam install ...`) actually
install the libraries and programs.

Most of Liquidsoap's dependencies are only optionally installed by opam. For
instance, if you want to enable ogg encoding and decoding after you've already
installed Liquidsoap, you should install the `vorbis` library by executing:

```
opam depext vorbis
opam install vorbis
```

opam will automatically detect that it can be used by Liquidsoap and will
recompile it. The list of all optional dependencies that you may enable in
Liquidsoap can be obtained by typing `opam info liquidsoap`, and is detailed
below.

### Installing the cutting-edge version

You can also install liquidsoap or any of its dependencies from source using
opam.^[TODO: retravailler ce paragraphe] For instance:

```
git clone https://github.com/savonet/liquidsoap.git
cd liquidsoap
opam pin add liquidsoap .
```

Most dependencies should be compatible with opam pinning.


Using binaries
--------------

If you want to avoid compiling Liquidsoap, or if opam is not working on your
platform, the easiest way is to use precompiled binaries of Liquidsoap, if
available.

### Linux

There are packages for Liquidsoap in most Linux distributions. For instance, in
Ubuntu or Debian, the installation can be performed by running

```
sudo apt-get install liquidsoap
```

which will install the `liquidsoap` package, containing the main binaries. It
comes equipped with most essential features, but you can install plugins in the
packages `liquidsoap-plugin-...` to have access to more libraries; for instance,
installing `liquidsoap-plugin-flac` will add support for the flac lossless audio
format or `liquidsoap-plugin-all` will install all available plugins (which
might be a good idea if you are not sure about which you are going to need).

On Ubuntu and Debian, you can also have access to the packages which are
automatically built for the latest version. This allows for quick testing of the
latest features, but we do not recommend them yet for production purposes. In
order to have access to those, first install the repository signing key:

```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 20D63CCDDD0F62C2
```

and then add the following source for Ubuntu:

```
sudo echo deb http://deb.liquidsoap.info/ubuntu bionic main >> /etc/apt/sources.list
```

The above line is for the Bionic version of Ubuntu, if you are on Debian/testing
or Debian/stretch, replace `bionic` by `testing` or `stretch`. Finally, update
your packages list:

```
sudo apt-get update
```

You can now see the list of available packages:
```
apt-cache show liquidsoap
```

Package versions are of the form: `1:0+<commit>~<distribution>-1` or
`1:0+<branch>~<distribution>-1`. The _commit_ is an identifier for the last
modification, the _distribution_ is the flavor of Linux it is made for and
_branches_ are used to develop features (the default branch being named
`master`). For instance, to install the latest `master` on
`debian/testing`, you can do:

```
sudo apt-get install liquidsoap=1:0+master~testing-1
```

### MacOS

No binaries are provided for MacOS, you should build from source (see below).

### Windows

Pre-built binaries are provided on the [releases
pages](https://github.com/savonet/liquidsoap/releases).

Building from source
--------------------

In some cases, it is necessary to build directly from source (e.g., if opam is
not supported on your exotic architecture or if you want to modify the source
code of Liquidsoap). This can be a difficult task, because Liquidsoap relies on
an up-to-date version of the OCaml compiler, as well as a bunch of OCaml modules
and, for most of them, corresponding C library dependencies (which is
automatically taken care of if you use opam for instance).

### Getting the sources of Liquidsoap

The sources of Liquidsoap, along with the required additional OCaml libraries we
maintain can be obtained using git:

```
git clone https://github.com/savonet/liquidsoap-full.git
cd liquidsoap-full
make init
make update
```

Alternatively, they bundled in the [`liquidsoap-<version>-full.tar.bz2` archive
on the release page](https://github.com/savonet/liquidsoap/releases).

### Installing external dependencies

In order to build Liquidsoap, you also need the following OCaml libraries:
`ocamlfind`, `sedlex`, `menhir`, `pcre` and `camomile` (which can be installed
using `opam install` or your package manager).

### Installing

In order to build Liquidsoap, go to the `liquidsoap-full` directory, generate
the `configure` scripts:

```
./bootstrap
```

and then run them:

```
./configure
```

This script optionally takes parameters such as `--prefix` which can be used to
specify in which directory the installation should be performed. Build everything

```
make
```

Then proceed to the installation, you may need to be root for that:

```
make install
```

Libraries used by Liquidsoap
----------------------------

TODO: explain all the libraries, sorted by theme

ex: ocaml-vorbis can be installed with opam install vorbis

for most of them you need the corresponding C library (e.g. `libsamplrate` for
`samplerate`)

### General

- `camomile`: charset recoding in metadata,

### Input / output

Soundcard:

- `ocaml-alsa`: soundcard input and output with ALSA,
- `ocaml-ao`: soundcard output using AO

Other:

- `ocaml-cry`: output to icecast servers,
- `ocaml-bjack`: Jack support

### Sound processing

- `ocaml-samplerate`: samplerate conversion in audio files,
- `ocaml-dssi`: support for sound synthesis plugins

### File formats

### Video

- `camlimages`: decoding of various image formats
- `gd4o`: rendering of text

### Optional dependencies (TODO: move this up)

| Dependency          | Version | Functionality                                 |
| ------------------- | ------- | --------------------------------------------- |
| ocaml-faad          | >=0.4.0 | AAC stream decoding                           |
| ocaml-fdkaac        | >=0.3.0 | AAC(+) encoding                               |
| ocaml-ffmpeg        | >=0.2.0 | Video conversion using the ffmpeg library     | 
| ocaml-flac          | >=0.1.5 | Flac and Ogg/Flac codec                       |
| ocaml-frei0r        | >=0.1.0 | Frei0r plugins                                |
| ocaml-gavl          | >=0.1.4 | Video conversion using the gavl library       |
| ocaml-gstreamer     | >=0.3.0 | GStreamer input, output and encoding/decoding |
| ocaml-inotify       | >=1.0   | Reloading playlists when changed              |
| ocaml-ladspa        | >=0.1.4 | LADSPA plugins                                |
| ocaml-lame          | >=0.3.2 | MP3 encoding                                  |
| ocaml-lastfm        | >=0.3.0 | Lastfm scrobbling                             |
| ocaml-lo            | >=0.1.0 | OSC (Open Sound Control) support              |
| ocaml-mad           | >=0.4.4 | MP3 decoding                                  |
| ocaml-magic         | >=0.6   | File type detection                           |
| ocaml-ogg           | >=0.5.0 | Ogg codecs                                    |
| ocaml-opus          | >=0.1.1 | Ogg/Opus codec                                |
| ocaml-portaudio     | >=0.2.0 | Portaudio I/O                                 |
| ocaml-pulseaudio    | >=0.1.2 | PulseAudio I/O                                |
| ocaml-sdl           |         | Display, font & image support                 |
| ocaml-shine         | >=0.2.0 | Fixed-point MP3 encoding                      |
| ocaml-soundtouch    | >=0.1.7 | Libsoundtouch's audio effects                 |
| ocaml-speex         | >=0.2.1 | Ogg/Speex codec                               |
| ocaml-ssl           | >=0.5.2 | SSL/https support                             |
| ocaml-taglib        | >=0.3.0 | MP3ID3 metadata access                        |
| ocaml-theora        | >=0.3.1 | Ogg/Theora codec                              |
| ocaml-vorbis        | >=0.7.0 | Ogg/Vorbis codec                              |
| ocaml-xmlplaylist   | >=0.1.3 | XML-based playlist formats                    |
| osx-secure-transport|         | SSL/https support via OSX's SecureTransport   |
| yojson              |         | Parsing JSON data (of_json function)          |

### Runtime optional dependencies (TODO)

| Dependency          | Functionality                                     |
| ------------------- | ------------------------------------------------- |
| awscli              | `s3://` and `polly://` protocol support           |
| curl                | `http`/`https`/`ftp` protocol support             |
| ffmpeg              | external I/O, `replay_gain` level computation, .. |
| youtube-dl          | youtube video and playlist support                |

