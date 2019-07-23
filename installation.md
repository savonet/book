Installation {#chap:installation}
============

In order to install Liquidsoap you should either download compiled binaries for
your environment, or compile it by yourself. The latest is slightly more
involved (although it is now a mostly automated process), but allows you to
easily obtain a cutting-edge version and take part of the development
process. These instructions are for the latest released version at the time of
the writing, you are encouraged to consult the online documentation 


Automated building using opam {#sec:opam}
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

It does take some minutes, because it compiles OCaml, so get prepared to have a
coffee.

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
install the libraries and programs. Again, compilation takes some time (around a
minute on a recent computer).

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

\TODO{retravailler ce paragraphe}

You can also install liquidsoap or any of its dependencies from source using
opam. For instance:

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

We list below some of the libraries which can be used by Liquidsoap. They are
detected during the compilation of Liquidsoap and, in this case, support for the
libraries is added. We recall that a library `ocaml-something` can be installed
via opam with

```
sudo opam depext something
sudo opam install something
```

which will automatically trigger a rebuild of Liquidsoap, see [above](#sec:opam).

### General

Those libraries add support for various things:

- `camomile`: charset recoding in metadata,
- `ocaml-inotify`: getting notified of file changes (e.g. for reloading
  playlists),
- `ocaml-magic`: file type detection,
- `ocaml-lo`: OSC (Open Sound Control) support,
- `ocaml-ssl`: SSL/https support for connecting to secured websites,
- `osx-secure-transport`: SSL/https support via OSX's SecureTransport,
- `yojson`: parsing JSON data.

### Input / output

Those libraries add support for using soundcard for output and input:

- `ocaml-alsa`: soundcard input and output with ALSA,
- `ocaml-ao`: soundcard output using AO,
- `ocaml-gstreamer`: input, output and much more,
- `ocaml-portaudio`: soundcard input and output,
- `ocaml-pulseaudio`: soundcard input and output.

Other outputs:

- `ocaml-cry`: output to icecast servers,
- `ocaml-bjack`: Jack support
- `ocaml-lastfm`: Lastfm scrobbling.

### Sound processing

Those add support for manipulate sound:

- `ocaml-samplerate`: samplerate conversion in audio files,
- `ocaml-dssi`: sound synthesis plugins,
- `ocaml-ladspa`: sound effect plugins,
- `ocaml-soundtouch`: pitch shifting and time stretching.

### Audio file formats

Support for various file formats (codecs):

- `ocaml-faad`: AAC decoding,
- `ocaml-fdkaac`: AAC+ encoding,
- `ocaml-flac`: Flac encoding and decoding,
- `ocaml-lame`: MP3 encoding,
- `ocaml-mad`: MP3 decoding,
- `ocaml-ogg`: Ogg containers,
- `ocaml-opus`: Ogg/Opus encoding and decoding,
- `ocaml-shine`: fixed-point MP3 encoding,
- `ocaml-speex`: Ogg/Speex encoding and decoding,
- `ocaml-taglib`: MP3 metadata decoding,
- `ocaml-vorbis`: Ogg/Vorbis encoding and decoding.

Support for playlists:

- `ocaml-xmlplaylist`: support for XML-based playlist formats.

### Video

Video conversion:

- `ocaml-ffmpeg`: video conversion,
- `ocaml-gavl`: video conversion,
- `ocaml-theora`: Ogg/Theora encoding and decoding.

Other video-related libraries:

- `camlimages`: decoding of various image formats,
- `gd4o`: rendering of text,
- `ocaml-frei0r`: video effects,
- `ocaml-sdl`: display, text rendering and image formats.

### Runtime dependencies

Those optional dependencies can be used by Liquidsoap if installed, they are
detected at runtime and do not require any particular support during
compilation:

- `awscli`: `s3://` and `polly://` protocol support for Amazon web servers,
- `curl`: downloading files with `http`, `https` and `ftp` protocols,
- `ffmpeg`: external input and output, `replay_gain`, level computation, and more,
- `youtube-dl`: youtube video and playlist downloading support.

