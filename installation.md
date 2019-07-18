Installation {#chap:installation}
============

**Note** These instructions are from the documentation from liquidsoap `1.4.0`.
Make sure to consult the latest online instructions from the version you wish to
install, most likely the latest stable release as these may have evolved since.

You can install liquidsoap with OPAM (recommended) or from source, or using a
package available for your distribution (not covered by this documentation).

Installing with Opam
--------------------

The recommended method to install liquidsoap is by using the [OCaml Package
Manager](http://opam.ocaml.org/). OPAM is available in all major distributions
and on windows. We actively support the liquidsoap packages there and its
dependencies. You can read [here](https://opam.ocaml.org/doc/Usage.html) about
how to use OPAM. In order to use it:

- [you should have at least OPAM version 2.0](https://opam.ocaml.org/doc/Install.html),
- you should have at least OCaml version 4.08.0, which can be achieved by typing
  ```
  opam switch create 4.08.0
  ```

A typical installation with MP3 and Vorbis encoding/decoding and icecast support
is done by executing:

```
opam depext taglib mad lame vorbis cry samplerate liquidsoap
opam install taglib mad lame vorbis cry samplerate liquidsoap
```

* `opam depext ...` takes care of installing the required external
  dependencies. In some cases external dependencies might be missing for your
  system. If that is the case, please report it to us!
* Finally `opam install ...` installs the packages themselves.

Most of liquidsoap's dependencies are only optionally installed by OPAM. For
instance, if you want to enable opus encoding and decoding after you've already
installed liquidsoap, you should execute the following:

```
opam depext opus
opam install opus
```

`opam info liquidsoap` should give you the list of all optional dependencies
that you may enable in liquidsoap.

If you need to run liquidsoap as daemon, we provide a package named
`liquidsoap-daemon`.  See
[savonet/liquidsoap-daemon](https://github.com/savonet/liquidsoap-daemon) for
more information.

You can also install liquidsoap or any of its dependencies from source using
OPAM. For instance:

```
git clone https://github.com/savonet/liquidsoap.git
cd liquidsoap
opam pin add liquidsoap .
```

Most dependencies should be compatible with OPAM pinning. Let us know if you
find one that isn't.

Installing in specific environments
-----------------------------------

### Ubuntu / Debian

We generate debian and ubuntu packages automatically as part of our CI workflow.
These packages are available for quick testing of `liquidsoap` on certain Debian
and Ubuntu distributions. However, we do not recommend them yet for production 
purposes.

Here's how to install:

* First install the repository signing key:
```
[sudo] apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 20D63CCDDD0F62C2
```
* Then one of the following source:

**debian/testing:**
```
[sudo] echo deb http://deb.liquidsoap.info/debian testing main >> /etc/apt/sources.list
```
**debian/stretch:**
```
[sudo] echo deb http://deb.liquidsoap.info/debian stretch main >> /etc/apt/sources.list
```
**ubuntu/bionic:**
```
[sudo] echo deb http://deb.liquidsoap.info/ubuntu bionic main >> /etc/apt/sources.list
```
* Finally, update your packages list:
```
[sudo] apt-get update
```

You can now see the list of available packages:
```
apt-cache show liquidsoap
```

Package versions are of the form: `1:0+<commit>~<distribution>-1` or `1:0+<branch>~<distribution>-1`. For instance,
to install the latest `master` on `debian/testing`, you can do:
```
[sudo] apt-get install liquidsoap=1:0+master~testing-1
```

### MacOS

For now, the best way to install liquidsoap on MacOS is via `opam`, as explained above.

### Windows

You can download a liquidsoap for windows from our [release
page](https://github.com/savonet/liquidsoap/releases), starting with version
`1.3.4`.

Liquidsoap for windows is built using [opam-cross](https://github.com/ocaml-cross/opam-cross-windows). The build process is documented in  our [docker files](https://github.com/savonet/liquidsoap-full/tree/master/docker). `Dockerfile.win32-deps` installs all  the [mxe](https://mxe.cc/) dependencies and `Dockerfile.win32` produces the actual liquidsoap binary.

You might want to refer to each project, [mxe](https://mxe.cc/) and [opam-cross](https://github.com/ocaml-cross/opam-cross-windows) for more details about cross-compiling for windows.

Building from source
--------------------

Installing liquidsoap can be a difficult task. The software relies on a up-to date
`OCaml` compiler, as well as a bunch of `OCaml` modules and, for most of them, corresponding
C library dependencies.

Our recommended way of installing liquidsoap is via [opam](http://opam.ocaml.org/). `opam` can take
care of install the correct `OCaml` compiler, optional and required dependencies as well as system-specific
package dependencies.

The following of this document describes how to install the software via its `configure` script and is
intended either for system administrators or package maintainers.

### Dependencies

Below is a list of dependencies, mostly OCaml libraries. Optional libraries
provide extra features. They need to be detected by the `configure` script.

Most of the libraries are developed by the Savonet project and, in addition to
being available through traditional distribution channels, are bundled in the
[liquidsoap-&lt;version&gt;-full.tar.bz2](https://github.com/savonet/liquidsoap/releases)
tarballs for easier builds.

Libraries not developed by Savonet are:

- camlimages
- camomile
- gd4o
- ocaml-pcre
- ocaml-magic
- ocaml-sdl
- yojson

#### Mandatory dependencies:

| Dependency     | Version   |
| -------------- | --------- |
| OCaml compiler | >= 4.08.0 |
| ocaml-dtools   | >= 0.4.0  |
| ocaml-duppy    | >= 0.6.0  |
| ocaml-mm       | >= 0.5.0  |
| ocaml-pcre     |           |
| menhir         |           |
| sedlex         |           |

#### Recommended dependencies:

| Dependency       | Version   | Functionality                  |
| ---------------- | --------- | ------------------------------ |
| camomile         | >=1.0.0   | Charset recoding in metadata   |
| ocaml-samplerate | >=0.1.1   | Libsamplerate audio conversion |

#### Optional dependencies:

| Dependency          | Version | Functionality                                 |
| ------------------- | ------- | --------------------------------------------- |
| camlimages          | >=4.0.0 | Image decoding                                |
| gd4o                |         | Video.add_text() on servers without X         |
| ocaml-alsa          | >=0.2.1 | ALSA I/O                                      |
| ocaml-ao            | >=0.2.0 | Output via libao                              |
| ocaml-bjack         | >=0.1.3 | Jack support                                  |
| ocaml-cry           | >=0.6.0 | Sending to Shoutcast & Icecast                |
| ocaml-dssi          | >=0.1.1 | DSSI sound synthesis                          |
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

#### Runtime optional dependencies:

| Dependency          | Functionality                                     |
| ------------------- | ------------------------------------------------- |
| awscli              | `s3://` and `polly://` protocol support           |
| curl                | `http`/`https`/`ftp` protocol support             |
| ffmpeg              | external I/O, `replay_gain` level computation, .. |
| youtube-dl          | youtube video and playlist support                |

    
#### Installing via configure

The build processus starts with by invoking the `configure` script:

```
% ./configure
```

If you want a complete installation of liquidsoap, enabling a production use of
liquidsoap as a daemon, you should pass `--with-user=<login>` and
`--with-group=<group>` options to indicate which user/group you have created for
liquidsoap.

Then, build the software:

```
% make
```

You can also generate the documentation for liquidsoap:

```
% make doc
```

It will generate the HTML documentation, including a version of the scripting
API reference corresponding to your configuration.

Then, you may proceed to the installation. You may need to be root for that.

```
% make install
```

This will not install files such as `/var/log/liquidsoap` unless you have provided
a user/group under which liquidsoap should be ran. This behavior can be
overridden by passing `INSTALL_DAEMON="yes"` (useful for preparing binary
packages).
