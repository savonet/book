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
opam](https://opam.ocaml.org/)\index{opam}. This program, which is available on all major
distributions and architectures, makes it easy to build programs written in
OCaml by installing the required dependencies (the libraries the program needs
to be compiled) and managing consistency between various versions (in
particular, it takes care of recompiling all the affected programs when a
library is installed or updated). Any user can install packages with opam, no
need to be root: the files it installs are stored in a subdirectory of the home
directory, named `.opam`. The opam packages for Liquidsoap and associated
libraries are actively maintained.

### Installing opam

The easiest way to install opam is by following the instructions on the [opam
install page](https://opam.ocaml.org/doc/Install.html), or by installing the
`opam` package with the package manager of your distribution, e.g., for
Ubuntu,

```
sudo apt install opam
```

In any case, you should ensure that you have at least version **2.1** of opam:
the version number can be checked by running `opam --version`.

If you are installing opam for the first time, you should initialize the list of
opam packages with

```
opam init
```

You can answer yes to all the questions it asks (if it complains about the
absence of `bwrap`, either install it or add the flag `--disable-sandboxing` to
the above command line). Next, you should install a supported version of the
OCaml compiler. Not all versions are supported; you can run

```
opam info liquidsoap-lang
```

to find out which OCaml versions are compatible. Then create a switch for your
chosen version:

```
opam switch create <ocaml version>
```

It does take a few minutes, because it compiles OCaml, so get prepared to have a
coffee.

### Installing Liquidsoap

Once this is done, a typical installation of Liquidsoap with most expected
features is done by executing:

```
opam install ffmpeg liquidsoap
```

This installs `liquidsoap` along with the optional `ffmpeg` package, which
provides most of the expected functionalities (encoding, decoding, metadata
support, etc.) out of the box. Starting with opam 2.1, external dependencies
(system libraries) are handled automatically — opam will ask for your permission
to install them or guide you through the process.

Most of Liquidsoap's dependencies are only optionally installed by opam. For
instance, if you want to enable ogg/vorbis encoding and decoding after you've
already installed Liquidsoap, you should install the `vorbis` library by
executing:

```
opam install vorbis
```

Opam will automatically detect that this library can be used by Liquidsoap and
will recompile it, resulting in added support for this format. The list of all
optional dependencies that you may enable in Liquidsoap can be obtained by
typing

```
opam info liquidsoap
```

and is detailed below.

**Note for macOS users**: when using [Homebrew](https://brew.sh/), you may need
to add the following to your shell configuration so that opam can find the
installed libraries:

```
export CPATH=/opt/homebrew/include
export LIBRARY_PATH=/opt/homebrew/lib
```

### Installing the cutting-edge version

The version of Liquidsoap which is packaged in opam is the latest release of the
software. However, you can also install the cutting-edge version of Liquidsoap,
for instance to test upcoming features. Beware that it might not be as stable as
a release, although this is generally the case: our policy enforces that the
developments in progress are performed apart, and integrated into the main
branch only once they have been tested and reviewed.

In order to install this version, you should first download the repository
containing all the code, which is managed using the git\index{git} version control system:

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

As an alternative to pinning from source, rolling release binaries are available
for upcoming versions — see [the section on versions and releases](#sec:versions)
below.

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

Binary packages and docker images are provided in two flavors:

- The main `liquidsoap` packages are compiled with all available features and
  functions. This is a good starting point for general-purpose development.
- Packages and images labelled `-minimal` are compiled without extra libraries
  and with a limited set of essential optional features. These are recommended
  for production if they meet your needs, as they reduce size, memory usage, and
  the chance of issues from unused optional dependencies.

Each binary build comes with a corresponding `*.config` file listing all
features included. You can also inspect a running installation with
`liquidsoap --build-config`.

### Linux

Official packages from the [Liquidsoap release
page](https://github.com/savonet/liquidsoap/releases) are available for Debian
and Ubuntu (see the supported releases table in the [versions
section](#sec:versions)). When using these packages on Debian, you will also
need to enable the [deb-multimedia.org](https://www.deb-multimedia.org/)
repositories, which provide up-to-date libraries including `fdk-aac` support in
FFmpeg.

Your distribution may also carry its own `liquidsoap` package (e.g. via
`sudo apt install liquidsoap`), though these may lag behind the latest release.

### macOS

No pre-built binaries are provided for macOS. The preferred installation method
is opam, as described above.

### Windows

Pre-built binaries are provided on the [releases
page](https://github.com/savonet/liquidsoap/releases) in a file with a name of
the form `liquidsoap-vN.N.N-win64.zip`. It contains directly the program, no
installer is provided at the moment.

Versions and releases {#sec:versions}
---------------------

### Semantic versioning

Liquidsoap releases follow semantic versioning:

```
<major_version>.<minor_version>.<bugfix_version>
```

- `major_version` is bumped for major changes (paradigm shifts, major
  implementation changes). Versions with different major numbers **are**
  incompatible.
- `minor_version` is bumped for minor changes (new operators, renames, new
  modules). Versions with different minor numbers **may be** incompatible.
- `bugfix_version` is bumped for bugfix releases. Only-bugfix-version changes
  **should be** compatible.

We strongly recommend maintaining a staging environment to test new versions
before deploying them in production.

### Current release status

| Branch  | Latest release | Supported | Rolling Release         |
|---------|----------------|-----------|-------------------------|
| `2.5.x` | (in dev)       | (dev)     | `main` branch           |
| `2.4.x` | 2.4.2          | \ding{51} | `rolling-release-v2.4.x` |
| `2.3.x` | 2.3.3          | \ding{55} | —                       |

### Rolling releases

A rolling release is a snapshot of a current, unpublished release — it may
become the next stable or bugfix release for a given major/minor version. Rolling
release assets may be updated, added, or removed at any time. For permanent,
immutable links to release assets, use
[liquidsoap-release-assets](https://github.com/savonet/liquidsoap-release-assets/releases).

### Supported operating systems for pre-built binaries

| OS      | Supported releases                                         | Architectures       | Notes                                                                              |
|---------|------------------------------------------------------------|---------------------|------------------------------------------------------------------------------------|
| Debian  | stable (`trixie`), testing (`forky`)                       | `amd64`, `arm64`    | `.deb` packages require [deb-multimedia.org](https://www.deb-multimedia.org/)      |
| Ubuntu  | LTS (`resolute`), latest (`plucky`)                        | `amd64`, `arm64`    |                                                                                    |
| Alpine  | `edge`                                                     | `x86_64`, `aarch64` |                                                                                    |
| Windows | N/A                                                        | 64-bit              | `.zip` archive                                                                     |

### Supported FFmpeg versions

Liquidsoap supports the last two major releases of FFmpeg. Currently, this means
versions **7** and **8**.

Building from source
--------------------

Building Liquidsoap from source is intended for developers who need to modify
the code or work on platforms not covered by the available binaries or opam.
It requires an up-to-date OCaml compiler and a number of OCaml libraries and
their C library dependencies.

For detailed and up-to-date build instructions, please refer to the [online
build documentation](https://www.liquidsoap.info/doc-dev/build.html).

Docker image
------------

[Docker](https://www.docker.com/)\index{Docker} images are provided as `savonet/liquidsoap`
on [Docker Hub](https://hub.docker.com/r/savonet/liquidsoap). These are
Debian-based images with Liquidsoap pre-installed (kept minimal for size), which
you can use to easily and securely deploy scripts.

Images are tagged with:

- a release version (e.g. `v2.4.2`) — note these may be updated,
- a git commit SHA (e.g. `a24bf49`) — these are permanent,
- a rolling-release tag (e.g. `rolling-release-v2.4.x`) — tracks the latest
  snapshot for that branch.

For example, to pull release `2.4.2`:

```
docker pull savonet/liquidsoap:v2.4.2
```

We refer the reader to the Docker documentation for the way such images can be
used. For instance, you can have a shell on such an image with

```
docker run -it --entrypoint /bin/bash savonet/liquidsoap:v2.4.2
```

By default, the docker image does not have access to the soundcard of the local
computer (but it can still be useful to stream over the internet for
instance). It is however possible to bind the ALSA soundcard of the host
computer inside the image. For instance, you can play a sine (see
[there](#sec:sound-sine)) by running:

```
docker run -it -v /dev/snd:/dev/snd --privileged savonet/liquidsoap:v2.4.2 liquidsoap 'output.alsa(sine())'
```

This single line should work on any computer on which Docker is installed: no
need to install opam, various libraries, or Liquidsoap, it will automatically
download for you an image where all this is pre-installed (if it does not work,
this probably means that docker does not have the rights to access the sound
device located at `/dev/snd`, in which case passing the additional option
`--group-add=audio` should help).

Libraries used by Liquidsoap
----------------------------

We list below some of the libraries which can be used by Liquidsoap. They are
detected during the compilation of Liquidsoap and, in this case, support for the
libraries is added. We recall that a library `ocaml-something` can be installed
via opam with

```
opam install something
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
- `ocaml-tls`: similar to `ocaml-ssl`,
- `ocurl`: downloading files over http,
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

Among those, pulseaudio is a safe default bet. ALSA is very low level and is
probably the one you want to use in order to minimize latencies. Other libraries
support a wider variety of soundcards and usages.

Other outputs:

- `ocaml-cry`: output to icecast servers,
- `ocaml-bjack`: Jack support for virtually connecting audio programs,
- `ocaml-lastfm`: Last.fm scrobbling (this website basically records the songs
  you have listened),
- `ocaml-srt`: transport over network using SRT protocol.

### Sound processing

Those add support for sound manipulation:

- `ocaml-dssi`: sound synthesis plugins,
- `ocaml-ladspa`: sound effect plugins,
- `ocaml-lilv`: sound effect plugins,
- `ocaml-samplerate`: samplerate conversion in audio files,
- `ocaml-soundtouch`: pitch shifting and time stretching.

### Audio file formats

- `ocaml-faad`: AAC decoding,
- `ocaml-fdkaac`: AAC+ encoding,
- `ocaml-ffmpeg`: encoding and decoding of various formats,
- `ocaml-flac`: Flac encoding and decoding,
- `ocaml-gstreamer`: encoding and decoding of various formats,
- `ocaml-lame`: MP3 encoding,
- `ocaml-mad`: MP3 decoding,
- `ocaml-ogg`: Ogg containers,
- `ocaml-opus`: Ogg/Opus encoding and decoding,
- `ocaml-shine`: fixed-point MP3 encoding,
- `ocaml-speex`: Ogg/Speex encoding and decoding,
- `ocaml-taglib`: metadata decoding,
- `ocaml-vorbis`: Ogg/Vorbis encoding and decoding.

### Playlists

- `ocaml-xmlplaylist`: support for playlist formats based on XML.

### Video

Video conversion:

- `ocaml-ffmpeg`: video conversion,
- `ocaml-gavl`: video conversion,
- `ocaml-theora`: Ogg/Theora encoding and decoding.

Other video-related libraries:

- `camlimages`: decoding of various image formats,
- `gd4o`: rendering of text,
- `ocaml-frei0r`: video effects,
- `ocaml-imagelib`: decoding of various image formats,
- `ocaml-sdl`: display, text rendering and image formats.

### Memory

Memory usage is sometimes an issue with some scripts:

- `ocaml-jemalloc`: support for jemalloc memory allocator which can avoid memory
  fragmentation and lower the memory footprint,
- `ocaml-memtrace`: support for tracing memory allocation in order to understand
  where memory consumption comes from,
- `ocaml-mem_usage`: detailed memory usage information.

### Runtime dependencies

Those optional dependencies can be used by Liquidsoap if installed, they are
detected at runtime and do not require any particular support during
compilation:

- `awscli`: `s3://` and `polly://` protocol support for Amazon web servers,
- `curl`: downloading files with `http`, `https` and `ftp` protocols,
- `ffmpeg`: external input and output, `replay_gain`, level computation, and more,
- `youtube-dl`: YouTube video and playlist downloading support.
