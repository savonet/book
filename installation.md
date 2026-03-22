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

If you also need a cutting-edge version of a library in the Liquidsoap ecosystem
(say, `ocaml-ffmpeg`), you can clone it and pin it directly with opam:

```
git clone https://github.com/savonet/ocaml-ffmpeg.git
cd ocaml-ffmpeg
opam pin add .
```

Opam will automatically detect the dependency and rebuild Liquidsoap.

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
page](https://github.com/savonet/liquidsoap/releases) are available for Debian,
Ubuntu, and Alpine (see the supported releases table in the [versions
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

| OS      | Supported releases                   | Architectures       | Notes                            |
|---------|--------------------------------------|---------------------|----------------------------------|
| Debian  | stable (`trixie`), testing (`forky`) | `amd64`, `arm64`    | needs [deb-multimedia.org](https://www.deb-multimedia.org/) repo |
| Ubuntu  | LTS (`resolute`), latest (`plucky`)  | `amd64`, `arm64`    |                                  |
| Alpine  | `edge`                               | `x86_64`, `aarch64` |                                  |
| Windows | N/A                                  | 64-bit              | `.zip` archive                   |

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

All names below refer to **opam package names** — install any of them with
`opam install <name>` and Liquidsoap will be automatically rebuilt with the
corresponding feature enabled. The full list of what is compiled into a
particular binary can be queried with `liquidsoap --build-config`.

Some libraries are always required and compiled in automatically: `camomile`
(metadata charset recoding), `curl` (HTTP downloads), `metadata` (tag reading),
`mem_usage` (memory reporting), and `magic-mime` (file-type detection by
content). The libraries listed below are all optional.

### General

- `inotify`: filesystem watch — reload playlists automatically when a file
  changes (Linux only; macOS uses a native equivalent),
- `lo`: OSC (Open Sound Control) support via liblo, for controlling Liquidsoap
  from phone apps or hardware controllers,
- `osc-unix`: pure-OCaml OSC alternative to `lo`,
- `ssl`: SSL/TLS support for `https://` connections,
- `tls-liquidsoap`: pure-OCaml TLS alternative to `ssl`,
- `irc-client-unix`: IRC chat output,
- `sqlite3`: SQLite database support (useful for playlist logging and history),
- `yaml`: YAML data parsing.

### Input / output

Soundcard input and output:

- `alsa`: ALSA — the low-level Linux soundcard interface, lowest latency,
- `ao`: AO — a cross-platform output-only library,
- `portaudio`: PortAudio — cross-platform input and output,
- `pulseaudio`: PulseAudio — the standard Linux audio server.

Network and device I/O:

- `ffmpeg`: input and output via FFmpeg (files, network streams, devices),
- `bjack`: JACK support for low-latency interconnection between audio programs,
- `srt`: transport over the network using the SRT protocol.

Icecast/Shoutcast streaming output is always compiled in (via the `cry`
library, which is a required dependency).

### Sound processing

- `dssi`: DSSI sound synthesis plugins,
- `ladspa`: LADSPA audio effect plugins,
- `lilv`: LV2 audio plugin support via Lilv,
- `samplerate`: high-quality sample rate conversion,
- `soundtouch`: pitch shifting and time stretching.

### Audio file formats

- `faad`: AAC decoding,
- `fdkaac`: AAC-LC/HE-AAC encoding via the Fraunhofer FDK library,
- `ffmpeg`: encoding and decoding of all FFmpeg-supported formats,
- `flac`: native FLAC encoding and decoding,
- `lame`: MP3 encoding via LAME,
- `mad`: MP3 decoding via MAD,
- `ogg`: Ogg container support,
- `opus`: Ogg/Opus encoding and decoding,
- `shine`: fixed-point MP3 encoding (useful on low-power devices),
- `speex`: Ogg/Speex encoding and decoding,
- `vorbis`: Ogg/Vorbis encoding and decoding.

### Video

- `ffmpeg`: video decoding, encoding, scaling and filtering,
- `theora`: Ogg/Theora video encoding and decoding,
- `camlimages`: decoding of common image formats (JPEG, PNG, GIF, …),
- `frei0r`: frei0r video effect plugins,
- `gd`: text and image rendering via the GD library,
- `graphics`: simple display via the OCaml Graphics library,
- `sdl-liquidsoap`: SDL2 display, font rendering, and image loading (meta-package
  that pulls the correct versions of `tsdl`, `tsdl-ttf`, and `tsdl-image`).

### Memory

- `jemalloc`: jemalloc allocator — reduces memory fragmentation on long-running
  scripts,
- `memtrace`: memory allocation tracing for diagnosing leaks.

### Monitoring

- `prometheus-liquidsoap`: exposes Liquidsoap metrics (sources, outputs, buffer
  levels, etc.) as a Prometheus endpoint for scraping by monitoring systems.

### Runtime dependencies

These are used by Liquidsoap at runtime if present on the system; they do not
affect compilation:

- `ffmpeg` CLI: used by some operators for external processing (e.g. ReplayGain
  analysis),
- `awscli`: enables the `s3://` and `polly://` protocols for Amazon Web Services,
- `yt-dlp` (or `youtube-dl`): enables downloading from YouTube and other
  video platforms via the `youtube://` protocol.
