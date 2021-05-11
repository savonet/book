Installation {#chap:installation}
============

In order to install Liquidsoap you should either download compiled binaries for
your environment, or compile it by yourself. The latest is slightly more
involved, although it is a mostly automated process, but it allows to easily
obtain a cutting-edge version and take part of the development process. These
instructions are for the latest released version at the time of the writing, you
are encouraged to consult the online documentation.

Automated building using opam {#sec:opam}
-----------------------------

The recommended method to install Liquidsoap is by using the [package manager
opam](http://opam.ocaml.org/). This program, which is available on all major
distributions and architectures, makes it easy to build programs written in
OCaml by installing the required dependencies (the libraries the program needs
to be compiled) and managing consistency between various versions (in
particular, it takes care of recompiling all the affected programs when a
library is installed or updated). Any user can install packages with opam, no
need to be root: the files it installs are stored in a subdirectory of the home
directory, named `.opam`. The opam packages for Liquidsoap and associated
libraries are actively maintained.

### Installing opam

The easiest way to install opam on any achitecture is by running the command

```
sh <(curl -sL https://git.io/fjMth)
```

or by installing the `opam` package with the package manager of your
distribution, e.g., for Ubuntu,

```
sudo apt install opam
```

or by downloading the binaries from [the opam
website](http://opam.ocaml.org/doc/Install.html). In any case, you should ensure
that you have at least the version 2.0.0 of opam: the version number can be
checked by running `opam --version`.

If you are installing opam for the first time, you should initialize the list of
opam packages with

```
opam init
```

You can answer yes to all the questions it asks (if it complains about the
absence of `bwrap`, either install it or add the flag `--disable-sandboxing` to
the above command line). Next thing, you should install a recent version of the
OCaml compiler by running

```
opam switch create 4.13.0
```

It does take a few minutes, because it compiles OCaml, so get prepared to have a
coffee.

### Installing Liquidsoap

Once this is done, a typical installation of Liquidsoap with support for mp3
encoding/decoding and Icecast is done by executing:

```
opam depext  taglib mad lame cry samplerate liquidsoap
opam install taglib mad lame cry samplerate liquidsoap
```

The first line (`opam depext ...`) takes care of installing the required
external dependencies, i.e., the libraries we are relying on, but did not
develop by ourselves. Here, we want to install the dependencies required by
`taglib` (the library to read tags in audio files), `mad` (to decode mp3),
`lame` (to encode mp3), `cry` (to stream to Icecast), `samplerate` (to resample
audio) and finally `liquidsoap`. The second line (`opam install ...`) actually
install the libraries and programs. Here also, the compilation takes some time
(around a minute on a recent computer).

Most of Liquidsoap's dependencies are only optionally installed by opam. For
instance, if you want to enable ogg/vorbis encoding and decoding after you've already
installed Liquidsoap, you should install the `vorbis` library by executing:

```
opam depext  vorbis
opam install vorbis
```

Opam will automatically detect that this library can be used by Liquidsoap and
will recompile it which will result in adding support for this format in
Liquidsoap. The list of all optional dependencies that you may enable in
Liquidsoap can be obtained by typing

```
opam info liquidsoap
```

and is detailed below.

### Installing the cutting-edge version

The version of Liquidsoap which is packaged in opam is the latest release of the
software. However, you can also install the cutting-edge version of Liquidsoap,
for instance to test upcoming features. Beware that it might not be as stable as
a release, although this is generally the case: our policy enforces that the
developments in progress are performed apart, and integrated into the main
branch only once they have been tested and reviewed.

In order to install this version, you should first download the repository
containing all the code, which is managed using the git version control system:

```
git clone https://github.com/savonet/liquidsoap.git
```

This will create a `liquidsoap` directory with the sources, and you can then
instruct opam to install Liquidsoap from this directory with the following
commands:

```
opam pin add liquidsoap .
```

From time to time you can update your version by downloading the latest code and
then asking opam to rebuild Liquidsoap:

```
git pull
opam upgrade liquidsoap
```

#### Updating libraries

If you also need a recent version of the libraries in the Liquidsoap ecosystem,
you can download all the libraries at once by typing

```
git clone https://github.com/savonet/liquidsoap-full.git
cd liquidsoap-full
make init
make update
```

You can then update a given library (say, `ocaml-ffmpeg`) by going in its
directory and pinning it with opam, e.g.

```
cd ocaml-ffmpeg
opam pin add .
```

(and answer yes if you are asked questions).

Using binaries
--------------

If you want to avoid compiling Liquidsoap, or if opam is not working on your
platform, the easiest way is to use precompiled binaries of Liquidsoap, if
available.

### Linux

There are packages for Liquidsoap in most Linux distributions. For instance, in
Ubuntu or Debian, the installation can be performed by running

```
sudo apt install liquidsoap
```

which will install the `liquidsoap` package, containing the main binaries. It
comes equipped with most essential features, but you can install plugins in the
packages `liquidsoap-plugin-...` to have access to more libraries; for instance,
installing `liquidsoap-plugin-flac` will add support for the flac lossless audio
format or `liquidsoap-plugin-all` will install all available plugins (which
might be a good idea if you are not sure about which you are going to need).

<!--
\TODO{apparently, cutting edge packages are not maintained anymore}

On Ubuntu and Debian, you can also have access to the packages which are
automatically built for the latest version. This allows for quick testing of the
latest features, but we do not recommend them for production purposes. In order
to have access to those, first install the repository signing key:

```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 20D63CCDDD0F62C2
```

and then add the following source for Ubuntu:

```
echo deb http://deb.liquidsoap.info/ubuntu bionic main | sudo tee -a /etc/apt/sources.list
```

The above line is for the Bionic version of Ubuntu, if you are on Debian/testing
or Debian/stretch, replace `ubuntu` by `debian` and `bionic` by `testing` or `stretch`.

Finally, update your packages list:

```
sudo apt update
```

You can now see the list of available packages:
```
apt-cache show liquidsoap
```

Package names are of the form: `liquidsoap-<commit>` or
`liquidsoap-<branch>`. _commit_ is an identifier for the last modification
and _branch_ are used to develop features (the default branch being named 
`master`). For instance, to install the latest `master`, you can do:

```
sudo apt install liquidsoap-master
```
-->

### MacOS

No binaries are provided for MacOS, the preferred method is opam, see above.

### Windows

Pre-built binaries are provided on the [releases
pages](https://github.com/savonet/liquidsoap/releases) in a file with a name of
the form `liquidsoap-vN.N.N-win64.zip`. It contains directly the program, no
installer is provided at the moment.

Building from source
--------------------

In some cases, it is necessary to build directly from source (e.g., if opam is
not supported on your exotic architecture or if you want to modify the source
code of Liquidsoap). This can be a difficult task, because Liquidsoap relies on
an up-to-date version of the OCaml compiler, as well as a bunch of OCaml
libraries and, for most of them, corresponding C library dependencies.

### Installing external dependencies

In order to build Liquidsoap, you first need to install the following OCaml
libraries: `ocamlfind`, `sedlex`, `menhir`, `pcre` and `camomile`. You can
install those using your package manager

```
sudo apt install ocaml-findlib libsedlex-ocaml-dev menhir libpcre-ocaml-dev libcamomile-ocaml-dev
```

(as you can remark, OCaml packages for Debian or Ubuntu often bear names of the
form `libxxx-ocaml-dev`), or using opam

```
opam install ocamlfind sedlex menhir pcre camomile
```

or from source.

### Getting the sources of Liquidsoap

The sources of Liquidsoap, along with the required additional OCaml libraries we
maintain can be obtained by downloading the main git repository, and then run
scripts which will download the submodules corresponding to the various
libraries:

```
git clone https://github.com/savonet/liquidsoap-full.git
cd liquidsoap-full
make init
make update
```

<!--
Alternatively, they bundled in the [`liquidsoap-<version>-full.tar.bz2` archive
on the release page](https://github.com/savonet/liquidsoap/releases).
-->

### Installing

Next, you should copy the file `PACKAGES.default` to `PACKAGES` and possibly
edit it: this file specifies which features and libraries are going to be
compiled, you can add/remove those by uncommenting/commenting the corresponding
lines. Then, you can generate the `configure` scripts:

```
./bootstrap
```

and then run them:

```
./configure
```

This script will check that whether the required external libraries are
available, and detect the associated parameters. It optionally takes parameters
such as `--prefix` which can be used to specify in which directory the
installation should be performed. You can now build everything

```
make
```

and then proceed to the installation

```
make install
```

You may need to be root to run the above command in order to have the right to
install in the usual directories for libraries and binaries.

Docker image
------------

[Docker](https://www.docker.com/) images are provided as `savonet/liquidsoap`:
these are Debian-based images with Liquidsoap pre-installed (and not much more
in order to have a file as small as possible), which you can use to easily and
securely deploy scripts using it. The tag `main` always contains the latest
version, and is automatically generated after each modification.

We refer the reader to the Docker documentation for the way such images can be
used. For instance, you can have a shell on such an image with

```
docker run -it --entrypoint /bin/bash savonet/liquidsoap:main
```

By default, the docker image does not have access to the soundcard of the local
computer (but it can still be useful to stream over the internet for
instance). It is however possible to bind the ALSA soundcard of the host
computer inside the image. For instance, you can play a sine by running:

```
docker run -it -v /dev/snd:/dev/snd --privileged savonet/liquidsoap:main liquidsoap 'output.alsa(sine())'
```

This single line should work on any computer on which Docker is installed: no
need to install opam, various libraries, or Liquidsoap, it will automatically
download for you an image where all this is pre-installed.

Libraries used by Liquidsoap
----------------------------

We list below some of the libraries which can be used by Liquidsoap. They are
detected during the compilation of Liquidsoap and, in this case, support for the
libraries is added. We recall that a library `ocaml-something` can be installed
via opam with

```
sudo opam depext  something
sudo opam install something
```

which will automatically trigger a rebuild of Liquidsoap, as explained in [the
above section](#sec:opam).

### General

Those libraries add support for various things:

- `camomile`: charset recoding in metadata (those are generally encoded in UTF-8
  which can represent all characters, but older files used various encodings for
  characters which can be converted),
- `ocaml-inotify`: getting notified when a file changes (e.g. for reloading a
  playlist when it has been updated),
- `ocaml-magic`: file type detection (e.g. this is useful for detecting that a
  file is an MP3 even if it does not have the `.mp3` extension),
- `ocaml-lo`: OSC (Open Sound Control) support for controlling the radio
  (changing the volume, switching between sources) via external interfaces
  (e.g. an application on your phone),
- `ocaml-ssl`: SSL support for connecting to secured websites (using the https
  protocol),
- `osx-secure-transport`: SSL support via OSX's SecureTransport,
- `yojson`: parsing JSON data (useful to exchange data with other applications).

### Input / output

Those libraries add support for using soundcards for playing and recording sound:

- `ocaml-alsa`: soundcard input and output with ALSA,
- `ocaml-ao`: soundcard output using AO,
- `ocaml-ffmpeg`: input and output over various devices,
- `ocaml-gstreamer`: input and output over various devices,
- `ocaml-portaudio`: soundcard input and output,
- `ocaml-pulseaudio`: soundcard input and output.

Among those, ALSA is very low level and is probably the one you want to use in
order to minimize latencies. Other support a wider variety of soundcards and
usages.

Other outputs:

- `ocaml-cry`: output to icecast servers,
- `ocaml-bjack`: Jack support,
- `ocaml-lastfm`: Last.fm scrobbling (this website basically records the songs
  you have listened),
- `ocaml-srt`: transport over network using SRT protocol.

### Sound processing

Those add support for manipulate sound:

- `ocaml-dssi`: sound synthesis plugins,
- `ocaml-ladspa`: sound effect plugins,
- `ocaml-lilv`: sound effect plugins,
- `ocaml-samplerate`: samplerate conversion in audio files,
- `ocaml-soundtouch`: pitch shifting and time stretching.

### Audio file formats

- `ocaml-faad`: AAC decoding,
- `ocaml-fdkaac`: AAC+ encoding,
- `ocaml-ffmepg`: encoding and decoding of various formats,
- `ocaml-flac`: Flac encoding and decoding,
- `ocaml-gstreamer`: encoding and decoding of various formats,
- `ocaml-lame`: MP3 encoding,
- `ocaml-mad`: MP3 decoding,
- `ocaml-ogg`: Ogg containers,
- `ocaml-opus`: Ogg/Opus encoding and decoding,
- `ocaml-shine`: fixed-point MP3 encoding,
- `ocaml-speex`: Ogg/Speex encoding and decoding,
- `ocaml-taglib`: MP3 metadata decoding,
- `ocaml-vorbis`: Ogg/Vorbis encoding and decoding.

### Playlists

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

