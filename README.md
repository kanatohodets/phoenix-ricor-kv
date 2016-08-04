# Phicor
### "Phoenix meets RiCor": `riak_core` + phoenix in an umbrella

This is a fairly complete example of a `riak_core` service that does something
basically useful: store and fetch blobs of data by key. That service is used by
a Phoenix API to make that storage available to the eager users. "Basically"
useful because this storage service is in-memory only, and does not provide any
sort of nuanced conflict resolution between competing concurrent writes: it
just clobbers the data.

That said, in-memory data services are webscale, so wooo!

### To run

    MIX_ENV=dev_a iex --name dev_a@127.0.0.1 -S mix phoenix.server
    MIX_ENV=dev_b iex --name dev_b@127.0.0.1 -S mix phoenix.server
    MIX_ENV=dev_c iex --name dev_c@127.0.0.1 -S mix phoenix.server

Then, in two of the 3 consoles:

    :riak_core.join('dev_b@127.0.0.1')

(There's a TODO to make this process smoother and more like the tooling found
in Mariano Guerra's
[work](https://github.com/marianoguerra/rebar3_template_riak_core)).

Now you'll have 3 phoenix applications running on `localhost:4000`, `4001`, and
`4002`.

Now you can work with the API:

    # send a 'ping' command to the vnode:
    curl -H "Content-Type: application/json" localhost:4000/api/ping

    # store some JSON under a key:
    curl -H "Content-Type: application/json" -XPUT -d '{"foo": [1, 2, 3]}' localhost:4000/api/store/my_cool_key

By default, `store` commands use an 'n' value of 3. This means they're written
to 3 different vnodes in the `riak_core` cluster. Which vnodes exactly is
determined by hashing the key: `my_cool_key`.

    # now fetch it back out:
    curl -H "Content-Type: application/json" -XGET localhost:4000/api/store/my_cool_key

`fetch` defaults to `n` of 1. This is not very robust to node failures.  If
one of the ring members goes down, we'll have better luck with `n=3`:

    curl -H "Content-Type: application/json" -XGET localhost:4000/api/store/my_cool_key?n=3

This will return multiple copies of the data, but better some than none, right?

### Compatibility (Erlang 18 only)
Riak Core has a fairly large dependency footprint, so often not everything
compiles on the latest Erlang. If you'd like to play around with Elixir and
Riak Core, for now you need to stick to Erlang 18.
