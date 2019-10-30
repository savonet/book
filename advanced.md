Advanced topics
===============

TODO: ce chapitre est un gros bordel mais ça va se décanter...

Runtime description
-------------------

Once a script has been parsed and compiled, liquidsoap will start the streaming
loop. The loop is animated from the outputs: for each clock, during one clock
cycle the streaming loop queries each output connected to that clock. These
outputs are given a frame to fill up, which contains all the data (audio, video,
midi) that will be produced during that clock cycle.

The frame size is calculated when starting liquidsoap and should be the smallest
size that can fit an interval of samples of each data type. Typically, a frame
for a audio rate of `44.1kHz` and video rate of `25Hz` fits `0.04s` of data. To
check this, look for the following lines in your liquidsoap logs:

```
[frame:3] Using 44100Hz audio, 25Hz video, 44100Hz master.
[frame:3] Frame size must be a multiple of 1764 ticks = 1764 audio samples = 1 video samples.
[frame:3] Targetting 'frame.duration': 0.04s = 1764 audio samples = 1764 ticks.
[frame:3] Frames last 0.04s = 1764 audio samples = 1 video samples = 1764 ticks.
```

During one clock cycle, each output is given one such frame to fill. All the
data is filled in-place, which avoids data copy as much as possible. When asked
to fill up a frame, each output passes its frame down to its connected
source. Then, for instance if the output is a `switch` operator, the operator
selects which source is ready and, in turn, passes the frame to be down to that
source. If a source is connected to multiple operators, it keeps a memoized
frame so that it does the computation required once during a single clock cycle,
sharing the result with all the operators it is connected to.

This goes on until the call returns. At this point, the frame is filled up with
data and metadata. Most calls will fill up the entire frame at once. If the
frame is only partially filled after one call, we consider that the current
track has ended. This defines a track mark, used in many operators such as
`on_track`. Then, if the source connected to the output is still available,
another call to fill up the frame is issued, still within the same clock
cycle. Otherwise, the output ends.

When a source is considered `infallible`, we assume that this source will
_always_ be able to fill up the current frame.

The runtime loop is important to keep in mind when trying to understand how
liquidsoap works. Clocks are at the core of it.  A normal clock will try to run
this streaming loop in real-time, speeding up when filling the frame takes more
time than the frame's length, which is when the infamous `catchup` log messages
will come up:

```
[clock.wallclock_main:2] We must catchup 2.82 seconds!
```

Furthermore, it is important to keep in mind that streaming happens by increment
of a frame's length. Typically, `source.time` is precise down to a frame
duration. This is also defines the I/O delay that you can expect when working
with liquidsoap. If you aim for a shorter one, specially when working with only
audio, try to lower the video rate.\RB{Man we need to detect that and not use
video when computing the frame size!}

Ids
---

TODO: explain that the name of an operator can generally be configured by
passing an `id` argument.

Settings
--------

[see here](https://www.liquidsoap.info/doc-dev/settings.html)

`--conf-descr`

Liquidsoap scripts contain expression like `set("log.stdout",true)`.
These are *settings*, global variables affecting the behaviour of the 
application.
Here, the first parameter identifies a setting its path,
and the second one specifies its new value.

You can have a list of available settings, with their documentation,
by running `liquidsoap --conf-descr`.
If you are interested in a particular settings section,
for example server-related stuff, use `liquidsoap --conf-descr-key server`.

The output of these commands is a valid liquidsoap script,
which you can edit to set the values that you want,
and load it ([implicitly](script_loading.html) or not) before you other scripts.

You can browse online the [list of available settings](settings.html).


### Logs

How to configure the logs (in particular default log.level is 3 so that info and
debug are not shown by default)

Using command-line arguments
----------------------------

argv (and argc)

Protocols
---------

There is a [list of
protocols](https://www.liquidsoap.info/doc-dev/protocols.html)

playing a file from youtube

annotate

Another way of using an external program is to define a new protocol which uses
it to resolve URIs. add_protocol takes a protocol name, a function to be used
for resolving URIs using that protocol. The function will be given the URI
parameter part and the time left for resolving – though nothing really bad
happens if you don’t respect it. It usually passes the parameter to an external
program, that’s how we use bubble for example:

```liquidsoap
add_protocol("bubble",
  fun (arg,delay) ->
    get_process_lines("/usr/bin/bubble-query "^quote(arg)))
```

When resolving the URI bubble:artist="seed", liquidsoap will call the function,
which will call bubble-query 'artist="seed"' which will output 10 lines, one URI
per line.

Protocols in liquidsoap are used to resolve requests URIs. The syntax is: `protocol:arguments`,
for instance: `http://www.example.com`, `say:Something to say` etc.

Most protocols are written using the script language. You can look at the file `protocols.liq` for a list
of them.

In particular, the `process:` protocol can use an external command to prepare resolve a request. Here's an example
using the AWS command-line to download a file from S3:

```
def s3_protocol(~rlog,~maxtime,arg) =
  extname = file.extension(dir_sep="/",arg)
  [process_uri(extname=extname,"aws s3 cp s3:#{arg} $(output)")]
end
add_protocol("s3",s3_protocol,doc="Fetch files from s3 using the AWS CLI",
             syntax="s3://uri")
```

Each protocol needs to register a handler, here the `s3_protocol` function. This function takes
the protocol arguments and returns a list of new requests or files. Liquidsoap will then call
this function, collect the returned list and keep resolving requests from the list until it finds a
suitable file.

This makes it possible to create your own custom resolution chain, including for instance cue-points. Here's an example:

```
def cue_protocol(~rlog,~maxtime,arg) =
  [process_uri(extname="wav",uri=uri,"ffmpeg -y -i $(input) -af -ss 10 -t 30 $(output)")]
end
add_protocol("cue_cut",cue_protocol)
```

This protocol returns 30s of data from the input file, stating at the 10s mark.

Likewise, you can apply a normalization program:

```
def normalization_protocol(~rlog,~maxtime,arg) =
  # "normalize" command here is just an example..
  [process_uri(extname="wav",uri=arg,"normalize $(inpuit)")]
end
add_protocol("normalize",normalization_protoco)
```

Now, you can push requests of the form: ```
normalize:cue_cut:http://www.server.com/file.mp3```
 and the file will be cut and normalized
before being played by liquidsoap.

When defining custom protocols, you should pay attention to two variables:

- `rlog` is the logging function. Messages passed to this function will be
  registered with the request and can be used to debug any issue
- `maxtime` is the maximun time (in UNIX epoch) that the requests should
  run. After that time, it should return and be considered timed out. You may
  want to read from `protocols.liq` to see how to enforce this when calling
  external processes.


Interaction with the server (telnet)
---------------------------

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

External scripting
------------------

Calling scripts in other languages...

Decoders
--------

TODO: changing the order of decoders, which decoders handle which format, etc. (settings)

Encoders
--------

TODO: encoding formats `%mp3`, `%wav`, main parameters (quality, numbers of
channels, etc.)

External decoders/encoders
--------------------------

TODO: many people want to use [stereotool](https://www.stereotool.com/), cf
https://github.com/savonet/liquidsoap/issues/885

Reading files
-------------

Requests
--------

TODO: explain the implementation of playlist.reloadable

TODO: explain that requests must be deleted, see https://github.com/savonet/liquidsoap/issues/309

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

* `dynamic_playlist.start <uri>`
* `dynamic_playlist.stop <uri>`

which you can use to create/destroy dynamically your sources.

With more tweaking, you should be able to adapt these ideas to your
precise needs.

If you want to plug those sources into an existing output, you may
want to use an `input.harbor` in the main output and change the
`output.icecast` in the dynamic source creation to send everything to
this `input.harbor`. You can use the `%wav` format in this case to avoid
compressing/decompressing the data.

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


Exiting
-------
mention `exit` and `shutdown` somewhere...

Offline processing
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
- `sleeper`
- what else?

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


Calling a function regurlarly
-----------------------------

`add_timeout`
