Advanced topics
===============

TODO: ce chapitre est un gros bordel mais ça va se décanter...

Interaction with the server (telnet) {#sec:telnet}
------------------------------------

TODO: le telnet est déjà couvert [ici](sec:telnet): merger

TODO: couvrir les sockets \TODO{we should also mention sockets, there is an
example in liq/request.queue.liq but it does not seem to be working right now,
see bug 1542, it does if we use `socat`}


TODO: ajout de commandes

TODO: `server.harbor` (exemple pour pousser dans une queue). Question: comment gérer l'authentification?

TODO: this should be the main section where everything is explained about telnet

TODO: use `nc` instead of `telnet`

You can add more commands to interact with your script through telnet or the server socket.

For instance, the following code, available in the standard API, attaches a source.skip command to a source. It is useful when the original source do not have a built-in skip command.

```liquidsoap
# Add a skip function to a source
# when it does not have one
# by default
def add_skip_command(s) =
 # A command to skip
 def skip(_) =
   source.skip(s)
   "Done!"
 end
 # Register the command:
 server.register(namespace="#{source.id(s)}",
                 usage="skip",
                 description="Skip the current song.",
                 "skip",skip)
end
```

Liquidsoap starts with one or several scripts as its configuration,
and then streams forever if everything goes well.
Once started, you can still interact with it by means of the *server*.
The server allows you to run commands. Some are general and always available,
some belong to a specific operator. For example the `request.queue()` instances register commands to enqueue new requests, the outputs register commands
to start or stop the outputting, display the last ten metadata chunks, etc.

The protocol of the server is a simple human-readable one.
Currently it does not have any kind of authentication and permissions.
It is currently available via two media: TCP and Unix sockets.
The TCP socket provides a simple telnet-like interface, available only on
the local host by default.
The Unix socket interface (*cf.* the `server.socket` setting)
is through some sort of virtual file.
This is more constraining, which allows one to restrict the use of the socket
to some priviledged users.

You can find more details on how to configure the server in the
[documentation](help.html#settings) of the settings key `server`,
in particular `server.telnet` for the TCP interface and `server.socket`
for the Unix interface.
Liquidsoap also embeds some [documentation](help.html#server)
about the available server commands.

Now, we shall simply enable the Telnet interface to the server,
by setting `set("server.telnet",true)` or simply passing the `-t` option on
the command-line.
In a [complete case analysis](complete_case.html) we set up a `request.queue()`
instance to play user requests. It had the identifier `"queue"`.
We are now going to interact via the server to push requests into that queue:

```
dbaelde@selassie:~$ telnet localhost 1234
Trying 127.0.0.1...
Connected to localhost.localdomain.
Escape character is '^]'.
request.push /path/to/some/file.ogg
5
END
metadata 5
[...]
END
request.push http://remote/audio.ogg
6
END
trace 6
[...see if the download started/succeeded...]
END
exit
```

Of course, the server isn't very user-friendly.
But it is easy to write scripts to interact with Liquidsoap in that way,
to implement a website or an IRC interface to your radio.
However, this sort of tool is often bound to a specific usage, so we have
not released any of ours. Feel free to
[ask the community](mailto:savonet-users@lists.sf.net) about code that you could re-use.

```liquidsoap
# Attach a skip command to the source s:
add_skip_command(s)
```

TODO: (re)explain interactive variables

TODO: maybe other interactions here : harbor / OSC

JSON import/export
------------------

### Exporting values

Liquidsoap can export any language value in JSON using `json_of`.

The format is the following :

* `() : unit` -> `null`
* `true: bool` -> `true`
* `"abc" : string` -> `"abc"`
* `23 : int` -> `23`
* `2.0 : float` -> `2.0`
* `[2,3,4] : [int]` -> `[2,3,4]`
* `[("f",1),("b",4)] : [(string*int)]` -> `{ "f": 1, "b": 4 }`
* `("foo",123) : string*int` -> `[ "foo", 123 ]`
* `s : source` -> `"<source>"`
* `r : ref(int)` -> `{ "reference":4 }`
* `%mp3 : format(...)` -> ```
"%mp3(stereo,bitrate=128,samplerate=44100)"```

* `r : request(...)` -> `"<request>"`
* `f : (...)->_` -> `"<fun>"`

The two particular cases are:

* Products are exported as lists.
* Lists of type `[(string*'a)]` are exported as objects of the form `{"key": value}`.

Output format is pretty printed by default. A compact output can
be obtained by using the optional argument: `compact=true`.

### Importing values

If compiled with `yojson` support, Liquidsoap can also
parse JSON data into values. using `of_json`.

The format is a subset of the format of exported values with the notable
difference that only ground types (`int`, `floats`, `string`, ...)
are supported and not variable references, sources, formats,
requests and functions:

* `null` -> `() : unit`
* `true/false` -> `true/false : bool`
* `"abc"` -> `"abc" : string`
* `23` -> `23 : int`
* `2.0` -> `2.0 : float`
* `[2,3,4]` -> `[2,3,4] : int`
* `{"f": 1, "b": 4}` -> `[("f",1),("b",4)] : [(string*int)]`
* `[ "foo", 123 ]` -> `("foo",123) : string*int`

The JSON standards specify that a proper JSON payload can only be an array or an
object. However, simple integers, floats, strings and null values are
also accepted by Liquidsoap.

The function `of_json` has the following type:

```
  (default:'a,string)->'a
```

The default parameter is very important in order to assure 
type inference of the parsed value. Its value constrains
the parser to only recognize JSON data of the the default value's 
type and is returned in case parsing fails.

Suppose that we want to receive a list of metadata, encoded as an object:

```
{ "title": "foo",
 "artist": "bar" }
```

Then, you would use of_json with default value `[("error","fail")]` and do:

```liquidsoap
# Parse metadata from json
m = of_json(default= [("error","fail")], json_string)
```

\TODO{note that it would not work with `default=[]` because we match the
type... Also explain that we cannot represent heterogeneous objects such as
`{"a": "a", "b": 5}`} The type of the default value constrains the parser. For
instance, in the above example, a JSON string `"[1,2,3,4]"` will not be accepted
and the function will return the values passed as default.

You can use the default value in two different ways:

- To detect that the received json string was invalid/could not be parsed to the
  expected type. In the example above, if `of_json` return a metadata value of
  `[("error","fail")]` (the default) then you can detect in your code that
  parsing has failed.
- As a default value for the rest of the script, if you do not want to care
  about parsing errors... This can be useful for instance for JSON-RPC
  notifications, which should not send any response to the client anyway.

If your JSON object is of mixed type, like this one:

```
{ "uri": "https://...",
  "metadata": { "title": "foo", "artist": "bar" } }
```

You can parse it in multiple steps. For instance:

```liquidsoap
# First parse key,value list:
hint = [("key","value")]
data = of_json(default=hint,payload)
print(data["uri"]) # "https://..."

# Then key -> (key,value) list
hint = [("list",[("key","value")])]
data = of_json(default=hint,payload)
m    = list.assoc(default=[],"metadata",data)
print(m["title"]) # "foo"
```

### A use case

TODO: typical use case, reading values from MySQL database, which [can export to
JSON](https://dev.mysql.com/doc/mysql-shell/8.0/en/mysql-shell-json-output.html)

Dealing with HTTP requests
--------------------------

all functions have an `https` variant

we can serve static pages with `harbor.http.static`

we can register dynamic pages with `harbor.http.register`: we can split
parameters with `url.split_args` and we should forge answers with
`http.response` (the interactive values example)

External scripting
------------------

Calling scripts in other languages...

explain that JSON is the preferred way of exchanging structured data

A queue fed from a script (if we have not already done this)

Decoders
--------

TODO: changing the order of decoders, which decoders handle which format, etc. (settings)

Encoders
--------

TODO: encoding formats `%mp3`, `%wav`, main parameters (quality, numbers of
channels, etc.)

TODO: also explain that we can both pass encoded contents and decode it with
`ffmpeg.decode` (see #1461).

External decoders/encoders
--------------------------

TODO: many people want to use [stereotool](https://www.stereotool.com/), cf
https://github.com/savonet/liquidsoap/issues/885

Requests
--------

TODO: explain the implementation of playlist.reloadable

TODO: explain that requests must be deleted, see https://github.com/savonet/liquidsoap/issues/309

TODO: explain how to trace requests

Dynamic sources
---------------

Liquidsoap supports dynamic creation and destruction of sources 
during the execution of a script. The following gives an example
of this.

First some outlines:

- This example is meant to create a new source and outputs. It is not easy
  currently to change a source being streamed
- The idea is to create a new output using a telnet/server command.

In this example, we will register a command that creates a playlist source using
an uri passed as argument and outputs it to a fixed icecast output.

With more work on parsing the argument passed to the telnet command, you may
write more evolved options, such as the possibility to change the output
parameters etc..

Due to some limitations of the language, we have used some intricate (but
classic) functional programming tricks. They are commented in order to help
reading the code..

New here's the code:

```liquidsoap
# First, we create a list referencing the dynamic sources:
dyn_sources = ref []

# This is our icecast output.
# It is a partial application: the source needs to be given!
out = output.icecast(%mp3,
                     host="test",
                     password="hackme",
                     fallible=true)

# Now we write a function to create 
# a playlist source and output it.
def create_playlist(uri) =
  # The playlist source 
  s = playlist(uri)

  # The output
  output = out(s)

  # We register both source and output 
  # in the list of sources
  dyn_sources := 
      list.append( [(uri,s),(uri,output)],
                    !dyn_sources )
  "Done!"
end

# And a function to destroy a dynamic source
def destroy_playlist(uri) = 
  # We need to find the source in the list,
  # remove it and destroy it. Currently, the language
  # lacks some nice operators for that so we do it
  # the functional way

  # This function is executed on every item in the list
  # of dynamic sources
  def parse_list(ret, current_element) = 
    # ret is of the form: (matching_sources, remaining_sources)
    # We extract those two:
    matching_sources = fst(ret)
    remaining_sources = snd(ret)

    # current_element is of the form: ("uri", source) so 
    # we check the first element
    current_uri = fst(current_element)
    if current_uri == uri then
      # In this case, we add the source to the list of
      # matched sources
      (list.append( [snd(current_element)], 
                     matching_sources),
       remaining_sources)
    else
      # In this case, we put the element in the list of remaining
      # sources
      (matching_sources,
       list.append([current_element], 
                    remaining_sources))
    end
  end
    
  # Now we execute the function:
  result = list.fold(parse_list, ([], []), !dyn_sources)
  matching_sources = fst(result)
  remaining_sources = snd(result)

  # We store the remaining sources in dyn_sources
  dyn_sources := remaining_sources

  # If no source matched, we return an error
  if list.length(matching_sources) == 0 then
    "Error: no matching sources!"
  else
    # We stop all sources
    list.iter(source.shutdown, matching_sources)
    # And return
    "Done!"
  end
end


# Now we register the telnet commands:
server.register(namespace="dynamic_playlist",
                description="Start a new dynamic playlist.",
                usage="start <uri>",
                "start",
                create_playlist)
server.register(namespace="dynamic_playlist",
                description="Stop a dynamic playlist.",
                usage="stop <uri>",
                "stop",
                destroy_playlist)
```

If you execute this code (add a `output.dummy(blank())` if you have
no other output..), you have two new telnet commands:

- `dynamic_playlist.start <uri>`
- `dynamic_playlist.stop <uri>`

which you can use to create/destroy dynamically your sources.

With more tweaking, you should be able to adapt these ideas to your
precise needs.

If you want to plug those sources into an existing output, you may
want to use an `input.harbor` in the main output and change the
`output.icecast` in the dynamic source creation to send everything to
this `input.harbor`. You can use the `%wav` format in this case to avoid
compressing/decompressing the data.

TODO: another example

```{.liquidsoap include="liq/source.dynamic.liq"}
```

and

```{.liquidsoap include="liq/source.dynamic-track.liq"}
```

#### Manually dump a stream
You may want to dump the content of 
a stream. The following code adds 
two server/telnet commands, `dump.start <filename>`
and `dump.stop` to dump the content of source s
into the file given as argument

```
# A source to dump
# s = (...) 

# A function to stop
# the current dump source
stop_f = ref (fun () -> ())
# You should make sure you never
# do a start when another dump
# is running.

# Start to dump
def start_dump(file_name) =
  # We create a new file output
  # source
  s = output.file(%vorbis,
            fallible=true,
            on_start={log("Starting dump with file #{file_name}.ogg")},
            reopen_on_metadata=false,
            "#{file_name}",
            s)
  # We update the stop function
  stop_f := fun () -> source.shutdown(s)
end

# Stop dump
def stop_dump() =
  f = !stop_f
  f ()
end

# Some telnet/server command
server.register(namespace="dump",
                description="Start dumping.",
                usage="dump.start <filename>",
                "start",
                fun (s) ->  begin start_dump(s) "Done!" end)
server.register(namespace="dump",
                description="Stop dumping.",
                usage="dump.stop",
                "stop",
                fun (s) -> begin stop_dump() "Done!" end)
```

Webcast
-------

Lastfm
------

Sandboxing {#sec:sandboxing}
----------

Daemon
------

If you need to run liquidsoap as daemon, we provide a package named
`liquidsoap-daemon`.  See
[savonet/liquidsoap-daemon](https://github.com/savonet/liquidsoap-daemon) for
more information.

The full installation of liquidsoap will typically install
`/etc/liquidsoap`, `/etc/init.d/liquidsoap` and `/var/log/liquidsoap`.
All these are meant for a particular usage of liquidsoap
when running a stable radio.

Your production `.liq` files should go in `/etc/liquidsoap`.
You'll then start/stop them using the init script, *e.g.*
`/etc/init.d/liquidsoap start`.
Your scripts don't need to have the `#!` line,
and liquidsoap will automatically be ran on daemon mode (`-d` option) for them.

You should not override the `log.file.path` setting because a
logrotate configuration is also installed so that log files
in the standard directory are truncated and compressed if they grow too big.

It is not very convenient to detect errors when using the init script.
We advise users to check their scripts after modification (use
`liquidsoap --check /etc/liquidsoap/script.liq`)
before effectively restarting the daemon.

Offline processing {#sec:offline-processing}
------------------

Explain how to use Liquidsoap to process files. For instance, converting to wav:

```{.liquidsoap include="liq/convert2wav.liq"}
```

of course we could also use it to

- apply audio effects (normalization, LADSPA, etc.)
- merge a playlist into one file

### Split and re-encode a CUE sheet.
CUE sheets are sometimes distributed along with a single audio file containing a whole CD.
Liquidsoap can parse CUE sheets as playlists and use them in your request-based sources.

Here's for instance an example of a simple code to split a CUE sheet into several mp3 files
with `id3v2` tags:

```liquidsoap
# Log to stdout
set("log.file",false)
set("log.stdout",true)
set("log.level",4)

# Initial playlist
cue = "/path/to/sheet.cue"

# Create a reloadable playlist with this CUE sheet.
# Tell liquidsoap to shutdown when we are done.
x = playlist.reloadable(cue, on_done=shutdown)

# We will never reload this playlist so we drop the first
# returned value:
s = snd(x)

# Add a cue_cut to cue-in/cue-out according to
# markers in "sheet.cue"
s = cue_cut(s)

# Shove all that to a output.file operator.
output.file(%mp3(id3v2=true,bitrate=320), 
            fallible=true,
            reopen_on_metadata=true,
            "/path/to/$(track) - $(title).mp3",
            s)
```

TODO: explain that if we run `liquidsoap mylib.liq myscript.liq -- a b` the
`argv.(1)` is the first after the `--`, which is used to separate scripts from
"real arguments"


Operations on sources {#sec:seek}
---------------------

- `source.seek`
- `source.time`
- etc.

Starting with Liquidsoap `1.0.0-beta2`, it is now possible to seek within
sources!  Not all sources support seeking though: currently, they are mostly
file-based sources such as `request.queue`, `playlist`, `request.dynamic` etc..

The basic function to seek within a source is `source.seek`. It has the
following type:

```
(source('a),float)->float
```

The parameters are:

* The source to seek.
* The duration in seconds to seek from current position.

The function returns the duration actually seeked.

Please note that seeking is done to a position relative to the *current*
position. For instance, `source.seek(s,3.)` will seek 3 seconds forward in
source `s` and `source.seek(s,(-4.))` will seek 4 seconds backward.

Since seeking is currently only supported by request-based sources, it is recommended
to hook the function as close as possible to the original source. Here is an example
that implements a server/telnet seek function:

```
# A playlist source
s = playlist("/path/to/music")

# The server seeking function
def seek(t) =
  t = float_of_string(default=0.,t)
  log("Seeking #{t} sec")
  ret = source.seek(s,t)
  "Seeked #{ret} seconds."
end

# Register the function
server.register(namespace=source.id(s),
                description="Seek to a relative position \
                             in source #{source.id(s)}",
                usage="seek <duration>",
                "seek",seek)
```

Testing scripts
---------------

- log as much as possible and use priorities meaningfully
- mention `chopper`, which is useful to simulate track boundaries
- `sine` etc are of course useful to generate sound, also `metronome`
- tracks can be generated with the `synth:` protocol
  (`"synth:shape=sine,frequency=880,duration=1`", default values (shape is sine,
  freq is 440, duration is 1))
- `sleeper`
- what else?

Full example:

```{.liquidsoap include="liq/ad-metadata.liq"}
```

Internal HTTP server
--------------------

### Harbor as HTTP server

The harbor server can be used as a HTTP server. You 
can use the function `harbor.http.register` to register
HTTP handlers. Its parameters are are follow:

```
harbor.http.register(port=8080,method="GET",uri,handler)
```

where:

- `port` is the port where to receive incoming connections
- `method` is for the http method (or verb), one of: `"GET"`, `"PUT"`, `"POST"`, `"DELETE"`, `"OPTIONS"` and `"HEAD"`
- `uri` is used to match requested uri. Perl regular expressions are accepted.
- `handler` is the function used to process requests.

`handler` function has type:

```
(~protocol:string, ~data:string, 
 ~headers:[(string*string)], string)->string))->unit
```

where:

* `protocol` is the HTTP protocol used by the client. Currently, one of `"HTTP/1.0"` or `"HTTP/1.1"`
* `data` is the data passed during a POST request
* `headers` is the list of HTTP headers sent by the client
* `string` is the (unparsed) uri requested by the client, e.g.: `"/foo?var=bar"`

The `handler` function returns HTTP and HTML data to be sent to the client,
for instance:

```
HTTP/1.1 200 OK\r\n\
Content-type: text/html\r\n\
Content-Length: 35\r\n\
\r\n\
<html><body>It works!</body></html>
```

(`\r\n` should always be used for line return
in HTTP content)

For convenience, a `http_response` function is provided to 
create a HTTP response string. It has the following type:

```
(?protocol:string,?code:int,?headers:[(string*string)],
 ?data:string)->string
```

where:

- `protocol` is the HTTP protocol of the response (default `HTTP/1.1`)
- `code` is the response code (default `200`)
- `headers` is the response headers. It defaults to `[]` but an appropriate `"Content-Length"` header is added if not set by the user and `data` is not empty.
- `data` is an optional response data (default `""`)

Thess functions can be used to create your own HTTP interface. Some examples
are:

#### Redirect Icecast's pages
Some source clients using the harbor may also request pages that
are served by an icecast server, for instance listeners statistics.
In this case, you can register the following handler:

```
# Redirect all files other
# than /admin.* to icecast,
# located at localhost:8000
def redirect_icecast(~protocol,~data,~headers,uri) =
   http_response(
     protocol=protocol,
     code=301,
     headers=[("Location","http://localhost:8000#{uri}")]
   )
end

# Register this handler at port 8005
# (provided harbor sources are also served
#  from this port).
harbor.http.register(port=8005,method="GET",
                     "^/(?!admin)",
                     redirect_icecast)
```

Another alternative, less recommended, is to
directly fetch the page's content from the Icecast server:

```
# Serve all files other
# than /admin.* by fetching data
# from Icecast, located at localhost:8000
def proxy_icecast(~protocol,~data,~headers,uri) =
  def f(x) =
    # Replace Host
    if string.capitalize(fst(x)) == "HOST" then
      "Host: localhost:8000"
    else
      "#{fst(x)}: #{snd(x)}"
    end
  end
  headers = list.map(f,headers)
  headers = string.concat(separator="\r\n",headers)
  request = 
    "#{method} #{uri} #{protocol}\r\n\
     #{headers}\r\n\r\n"
  get_process_output("echo #{quote(request)} | \
                      nc localhost 8000")
end

# Register this handler at port 8005
# (provided harbor sources are also served
#  from this port).
harbor.http.register(port=8005,method="GET",
                     "^/(?!admin)",
                     proxy_icecast)
```

This method is not recommended because some servers may not
close the socket after serving a request, causing `nc` and
liquidsoap to hang.

#### Get metadata
You can use harbor to register HTTP services to 
fecth/set the metadata of a source. For instance, 
using the [JSON export function](json.html) `json_of`:

```
meta = ref []

# s = some source

# Update current metadata
# converted in UTF8
def update_meta(m) =
  m = metadata.export(m)
  recode = string.recode(out_enc="UTF-8")
  def f(x) =
    (recode(fst(x)),recode(snd(x)))
  end
  meta := list.map(f,m)
end

# Apply update_metadata
# every time we see a new
# metadata
s = on_metadata(update_meta,s)

# Return the json content
# of meta
def get_meta(~protocol,~data,~headers,uri) =
  m = !meta
  http_response(
    protocol=protocol,
    code=200,
    headers=[("Content-Type","application/json; charset=utf-8")],
    data=json_of(m)
  )
end

# Register get_meta at port 700
harbor.http.register(port=7000,method="GET","/getmeta",get_meta)
```

Once the script is running, 
a GET/POST request for `/getmeta` at port `7000`
returns the following:

```
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8

{
  "genre": "Soul",
  "album": "The Complete Stax-Volt Singles: 1959-1968 (Disc 8)",
  "artist": "Astors",
  "title": "Daddy Didn't Tell Me"
}
```

Which can be used with AJAX-based backends to fetch the current 
metadata of source `s`

#### Set metadata
Using `insert_metadata`, you can register a GET handler that
updates the metadata of a given source. For instance:

```

# s = some source

# x is of type ((metadata)->unit)*source
# first part is a function used to update
# metadata and second part is the source 
# whose metadata are updated
x = insert_metadata(s)

# Get the function
insert = fst(x)

# Redefine s as the new source
s = snd(x)

# The handler
def set_meta(~protocol,~data,~headers,uri) =
  # Split uri of the form request?foo=bar&...
  # into (request,[("foo","bar"),..])
  x = url.split(uri)

  # Filter out unusual metadata
  meta = metadata.export(snd(x))
  
  # Grab the returned message
  ret =
    if meta != [] then
      insert(meta)
      "OK!"
    else
      "No metadata to add!"
  end

  # Return response
  http_response(
   protocol=protocol,
   code=200,
   headers=[("Content-Type","text/html")],
   data="<html><body><b>#{ret}</b></body></html>"
  )
end

# Register handler on port 700
harbor.http.register(port=7000,method="GET","/setmeta",set_meta)
```

Now, a request of the form `http://server:7000/setmeta?title=foo`
will update the metadata of source `s` with `[("title","foo")]`. You
can use this handler, for instance, in a custom HTML form.

### File requests

TODO: an example of a request queue with harbor (see #949).

### Limitations
When using harbor's HTTP server, please be warned that the server is **not**
meant to be used under heavy load. Therefore, it should **not** be exposed to
your users/listeners if you expect many of them. In this case, you should use it
as a backend/middle-end and have some kind of caching between harbor and the
final user. In particular, the harbor server is not meant to server big files
because it loads their entire content in memory before sending them. However,
the harbor HTTP server is fully equipped to serve any kind of CGI script.

Operations on sources
---------------------

`on_end`, `source.skip`, `source.on_shutdown`, `on_track`, etc.

Profiling
---------

`profiler.enable`, `profiler.stats.string`

Observing the signal
--------------------

Compute RMS and LUFS, conversion with `dB_of_lin` and conversely, `vumeter`, etc.

TODO: expose metrics with JSON on harbor

```{.liquidsoap include="liq/metrics-harbor.liq" from=1}
```

TODO: explain the variant where we store on a file regularly

```{.liquidsoap include="liq/metrics-file.liq" from=1}
```

TODO: expose metrics with prometeus

SRT
---

Usage of srt....... example with ffplay

also mention `input.udp`

Protocols
---------

- the `synth` protocol (already presented in "testing scripts" section)

FFmpeg filters
--------------


Clocks {#sec:clocks-ex}
------

Explain the problem with multiple icecast outputs.

In the [quickstart](quick_start.html) and in the introduction to liquidsoap
[sources](sources.html), we have described a simple world in which sources
communicate with each other, creating and transforming data that
composes multimedia streams.
In this simple view, all sources produce data at the same rate,
animated by a single clock: at every cycle of the clock,
a fixed amount of data is produced.

While this simple picture is useful to get a fair idea of what's going on
in liquidsoap, the full picture is more complex: in fact, a streaming
system might involve *multiple clocks*, or in other words several
time flows.

It is only in very particular cases that liquidsoap scripts
need to mention clocks explicitly. Otherwise, you won't even notice
how many clocks are involved in your setup: indeed, liquidsoap can figure
out the clocks by itself, much like it infers types.
Nevertheless, there will sometimes be cases where your script cannot
be assigned clocks in a correct way, in which case liquidsoap will
complain. For that reason, every user should eventually get a minimum
understanding of clocks.

In the following, we first describe why we need clocks.
Then we go through the possible errors that any user might encounter
regarding clocks.
Finally, we describe how to explicitly use clocks,
and show a few striking examples of what can be achieved that way.

### Why multiple clocks

The first reason is **external** to liquidsoap: there is simply
not a unique notion of time in the real world.
Your computer has an internal clock which indicates
a slightly different time than your watch or another computer's clock.
Moreover, when communicating with a remote computer, network
latency causes extra time distortions.
Even within a single computer there are several clocks: notably, each
soundcard has its own clock, which will tick at a slightly different
rate than the main clock of the computer.
Since liquidsoap communicates with soundcards and remote computers,
it has to take those mismatches into account.

There are also some reasons that are purely **internal** to liquidsoap:
in order to produce a stream at a given speed,
a source might need to obtain data from another source at
a different rate. This is obvious for an operator that speeds up or
slows down audio (`stretch`). But it also holds more subtly
for `cross`, `cross` as well as the
derived operators: during the lapse of time where the operator combines
data from an end of track with the beginning of the other other,
the crossing operator needs twice as much stream data. After ten tracks,
with a crossing duration of six seconds, one more minute will have
passed for the source compared to the time of the crossing operator.

In order to avoid inconsistencies caused by time differences,
while maintaining a simple and efficient execution model for
its sources, liquidsoap works under the restriction that
one source belongs to a unique clock,
fixed once for all when the source is created.

The graph representation of streaming systems can be adapted
into a good representation of what clocks mean.
One simply needs to add boxes representing clocks:
a source can belong to only one box,
and all sources of a box produce streams at the same rate.
For example, 

```liquidsoap
output.icecast(fallback([crossfade(playlist(...)),jingles]))
```

yields the following graph:

![Graph representation with clocks](images/graph_clocks.png)

Here, clock_2 was created specifically for the crossfading
operator; the rate of that clock is controlled by that operator,
which can hence accelerate it around track changes without any
risk of inconsistency.
The other clock is simply a wallclock, so that the main stream
is produced following the ``real'' time rate.

### Error messages
Most of the time you won't have to do anything special about clocks:
operators that have special requirements regarding clocks will do
what's necessary themselves, and liquidsoap will check that everything is 
fine. But if the check fails, you'll need to understand the error,
which is what this section is for.

#### Disjoint clocks
On the following example, liquidsoap will issue the fatal error
`a source cannot belong to two clocks`:

```liquidsoap
s = playlist("~/media/audio")
output.alsa(s) # perhaps for monitoring
output.icecast(mount="radio.ogg",%vorbis,crossfade(s))
```

Here, the source `s` is first assigned the ALSA clock,
because it is tied to an ALSA output.
Then, we attempt to build a `crossfade` over `s`.
But this operator requires its source to belong to a dedicated
internal clock (because crossfading requires control over the flow
of the of the source, to accelerate it around track changes).
The error expresses this conflict:
`s` must belong at the same time to the ALSA clock
and `crossfade`'s clock.

##### Nested clocks
On the following example, liquidsoap will issue the fatal error
`cannot unify two nested clocks`:

```liquidsoap
jingles = playlist("jingles.lst")
music = rotate([1,10],[jingles,playlist("remote.lst")])
safe = rotate([1,10],[jingles,single("local.ogg")])
q = fallback([crossfade(music),safe])
```

Let's see what happened.
The `rotate` operator, like most operators, operates
within a single clock, which means that `jingles`
and our two `playlist` instances must belong to the same clock.
Similarly, `music` and `safe` must belong to that
same clock.
When we applied crossfading to `music`,
the `crossfade` operator created its own internal clock,
call it `cross_clock`,
to signify that it needs the ability to accelerate at will the
streaming of `music`.
So, `music` is attached to `cross_clock`,
and all sources built above come along.
Finally, we build the fallback, which requires that all of its
sources belong to the same clock.
In other words, `crossfade(music)` must belong
to `cross_clock` just like `safe`.
The error message simply says that this is forbidden: the internal
clock of our crossfade cannot be its external clock -- otherwise
it would not have exclusive control over its internal flow of time.

The same error also occurs on `add([crossfade(s),s])`,
the simplest example of conflicting time flows, described above.
However, you won't find yourself writing this obviously problematic
piece of code. On the other hand, one would sometimes like to
write things like our first example.

The key to the error with our first example is that the same
`jingles` source is used in combination with `music`
and `safe`. As a result, liquidsoap sees a potentially
nasty situation, which indeed could be turned into a real mess
by adding just a little more complexity. To obtain the desired effect
without requiring illegal clock assignments, it suffices to
create two jingle sources, one for each clock:

```liquidsoap
music = rotate([1,10],[playlist("jingles.lst"),
                       playlist("remote.lst")])
safe  = rotate([1,10],[playlist("jingles.lst"),
                       single("local.ogg")])
q = fallback([crossfade(music),safe])
```

There is no problem anymore: `music` belongs to 
`crossfade`'s internal clock, and `crossfade(music)`,
`safe` and the `fallback` belong to another clock.

#### The clock API
There are only a couple of operations dealing explicitly with clocks.

The function `clock.assign_new(l)` creates a new clock
and assigns it to all sources from the list `l`.
For convenience, we also provide a wrapper, `clock(s)`
which does the same with a single source instead of a list,
and returns that source.
With both functions, the new clock will follow (the computer's idea of)
real time, unless `sync=false` is passed, in which case
it will run as fast as possible.

The old (pre-1.0.0) setting `root.sync` is superseded
by `clock.assign_new()`.
If you want to run an output as fast as your CPU allows,
just attach it to a new clock without synchronization:

```liquidsoap
clock.assign_new(sync=false,[output.file(%vorbis,"audio.ogg",source)])
```

This will automatically attach the appropriate sources to that clock.
However, you may need to do it for other operators if they are totally
unrelated to the first one.

\TODO{mention the `buffer.adaptative` operator}
The `buffer()` operator can be used to communicate between
any two clocks: it takes a source in one clock and builds a source
in another. The trick is that it uses a buffer: if one clock
happens to run too fast or too slow, the buffer may empty or overflow.

Finally, `get_clock_status` provides information on
existing clocks and track their respective times:
it returns a list containing for each clock a pair
`(name,time)` indicating
the clock id its current time in *clock cycles* --
a cycle corresponds to the duration of a frame,
which is given in ticks, displayed on startup in the logs.
The helper function `log_clocks` built
around `get_clock_status` can be used to directly
obtain a simple log file, suitable for graphing with gnuplot.
Those functions are useful to debug latency issues.

### External clocks: decoupling latencies
The first reason to explicitly assign clocks is to precisely handle
the various latencies that might occur in your setup.

Most input/output operators (ALSA, AO, Jack, OSS, etc)
require their own clocks. Indeed, their processing rate is constrained
by external sound APIs or by the hardware itself.
Sometimes, it is too much of an inconvenience,
in which case one can set `clock_safe=false` to allow
another clock assignment --
use at your own risk, as this might create bad latency interferences.

Currently, `output.icecast` does not require to belong
to any particular clock. This allows to stream according to the
soundcard's internal clock, like in most other tools:
in

```liquidsoap
output.icecast(%vorbis,mount="live.ogg",input.alsa())
```
,
the ALSA clock will drive the streaming of the soundcard input via
icecast.

Sometimes, the external factors tied to Icecast output cannot be
disregarded: the network may lag. If you stream a soundcard input
to Icecast and the network lags, there will be a glitch in the
soundcard input -- a long enough lag will cause a disconnection.
This might be undesirable, and is certainly disappointing if you
are recording a backup of your precious soundcard input using
`output.file`: by default it will suffer the same
latencies and glitches, while in theory it could be perfect.
To fix this you can explicitly separate Icecast (high latency,
low quality acceptable) from the backup and soundcard input (low latency,
high quality wanted):

```liquidsoap
input = input.oss()

clock.assign_new(id="icecast",
  [output.icecast(%mp3,mount="blah",mksafe(buffer(input)))])

output.file(
  %mp3,"record-%Y-%m-%d-%H-%M-%S.mp3",
  input)
```

Here, the soundcard input and file output end up in the OSS
clock. The icecast output
goes to the explicitly created `"icecast"` clock,
and a buffer is used to
connect it to the soundcard input. Small network lags will be
absorbed by the buffer. Important lags and possible disconnections
will result in an overflow of the buffer.
In any case, the OSS input and file output won't be affected
by those latencies, and the recording should be perfect.
The Icecast quality is also better with that setup,
since small lags are absorbed by the buffer and do not create
a glitch in the OSS capture, so that Icecast listeners won't
notice the lag at all.

### Internal clocks: exploiting multiple cores
Clocks can also be useful even when external factors are not an issue.
Indeed, several clocks run in several threads, which creates an opportunity
to exploit multiple CPU cores.
The story is a bit complex because OCaml has some limitations on
exploiting multiple cores, but in many situations most of the computing
is done in C code (typically decoding and encoding) so it parallelizes
quite well.

Typically, if you run several outputs that do not share much (any) code,
you can put each of them in a separate clock.
For example the following script takes one file and encodes it as MP3
twice. You should run it as `liquidsoap EXPR -- FILE`
and observe that it fully exploits two cores:

```liquidsoap
def one()
  clock.assign_new(sync=false,
        [output.file(%mp3,"/dev/null",single(argv(1)))])
end
one()
one()
```

TODO: explain the operators who need to be clocked for instance, we had the
following question: Yamakaky [5:20 PM] Does `input.harbor` require the use of
`clock` and `buffer`? It has an internal buffer so I would say no?
