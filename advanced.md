Advanced features
=================

Ids
---

TODO: explain that the name of an operator can generally be configured by
passing an `id` argument.

Settings
--------

[see here](https://www.liquidsoap.info/doc-dev/settings.html)

Using command-line arguments
----------------------------

shebang, argv

Protocols
---------

There is a [list of
protocols](https://www.liquidsoap.info/doc-dev/protocols.html)

playing a file from youtube

annotate

Interaction with the server
---------------------------

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

The type of the default value constrains the parser. For instance, in the 
above example, a JSON string `"[1,2,3,4]"` will not be accepted and the 
function will return the values passed as default.

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

Dealing with HTTP requests
--------------------------

External scripting
------------------

Calling scripts in other languages...

Decoders
--------

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

* This example is meant to create a new source and outputs. It is not easy currently to change a source being streamed
* The idea is to create a new output using a telnet/server command.

In this example, we will register a command that creates a playlist source using an uri passed
as argument and outputs it to a fixed icecast output.

With more work on parsing the argument passed to the telnet command,
you may write more evolved options, such as the possibility to change
the output parameters etc..

Due to some limitations of the language, we have used some
intricate (but classic) functional programming tricks. They are
commented in order to help reading the code..

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
  # remove it and destroy it. Currently, the language
  # lacks some nice operators for that so we do it
  # the functional way

  # This function is executed on every item in the list
  # of dynamic sources
  def parse_list(ret, current_element) = 
    # ret is of the form: (matching_sources, remaining_sources)
    # We extract those two:
    matching_sources = fst(ret)
    remaining_sources = snd(ret)

    # current_element is of the form: ("uri", source) so 
    # we check the first element
    current_uri = fst(current_element)
    if current_uri == uri then
      # In this case, we add the source to the list of
      # matched sources
      (list.append( [snd(current_element)], 
                     matching_sources),
       remaining_sources)
    else
      # In this case, we put the element in the list of remaining
      # sources
      (matching_sources,
       list.append([current_element], 
                    remaining_sources))
    end
  end
    
  # Now we execute the function:
  result = list.fold(parse_list, ([], []), !dyn_sources)
  matching_sources = fst(result)
  remaining_sources = snd(result)

  # We store the remaining sources in dyn_sources
  dyn_sources := remaining_sources

  # If no source matched, we return an error
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
compressing/decompressing the data..

Lastfm
------

Daemon
------

If you need to run liquidsoap as daemon, we provide a package named
`liquidsoap-daemon`.  See
[savonet/liquidsoap-daemon](https://github.com/savonet/liquidsoap-daemon) for
more information.
