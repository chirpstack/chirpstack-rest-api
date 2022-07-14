# ChirpStack gRPC to REST API proxy

The ChirpStack gRPC to REST API proxy exposes the ChirpStack (v4) gRPC as REST
API. While the gRPC API interface exposed by ChirpStack (v4) is recommended,
in some use-cases a REST API cna be more convenient. It could also help when
migrating from ChirpStack v3 to v4 as previously this proxy was embedded inside
the ChirpStack Application Server.

## Usage

```bash
chirpstack-rest-api --server localhost:8080 --bind 0.0.0.0:8090 --insecure
```

* `--server` points to the ChirpStack gRPC endpoint. If ChirpStack is installed
  on the same machine and uses port `8080` (default), you can use the default
  value. You can also use the environment variable `SERVER`.
* `--bind` defines to which interface and port the REST API server will bind.
  In the above example (and default value), the REST API server will be exposed
  on port `8090`. YOu can also use the environment variable `BIND`.
* `--insecure` indicates that the gRPC interface is not secured using a TLS
  certificate. You can also use the environment variable `INSECURE` (setting
  this to any value enables insecure mode, e.g. do not use `INSECURE=false`!).

## Building from source

To start the Docker Compose based development environment:

```
make devshell
```

Within this development shell, you can use one of the following commands
(see also the included `Makefile`):

```bash
# Compile binary
make build

# Create distributable archives and packages.
make dist

# Create snapshot archives and packages.
make snapshot

# Re-generate API definitions (VERSION must be set to the ChirpStack version)
VERSION=v4.0.0 make generate
```

## License

ChirpStack REST API is distributed under the MIT license. See also
[LICENSE](https://github.com/chirpstack/chirpstack-rest-api/blob/master/LICENSE).
