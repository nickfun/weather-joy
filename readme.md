
# Weather, Powered by Joy Framework

A cool project to tell you the weather.

## Build and Use, dev notes

- `jpm build` will creat the `build/app` executable. Run it with `./build/app`
- `jpm run format` to reformat the janet code
- `jpm run server` to start the server without a full build
- `tk ready` to show tickets that need to be worked on
- `tk ls` to show all tickets
- `tk create` to make a new ticket

## To look up the weather

```
curl -H "User-Agent: (myweatherapp, contact@example.com)" \
  "https://api.weather.gov/points/37.8044,-122.2712"
```

## To get LAT LONG from an address - USA

```
curl -G "https://geocoding.geo.census.gov/geocoder/locations/onelineaddress" \
  --data-urlencode "address=14900 E 14th St, San Leandro, CA 94578" \
  --data-urlencode "benchmark=Public_AR_Current" \
  --data-urlencode "format=json"
```


## when benchmarking

```sh
ab -n 4 -c 1 -H 'Connection: close' 'http://[::1]:9292/?a=b'
```

You need the Connection header or else `ab` will think the connection should stay open.
