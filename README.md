# ChirpStack gRPC to REST API proxy

The ChirpStack gRPC to REST API proxy exposes the ChirpStack (v4) gRPC as REST
API. While the gRPC API interface exposed by ChirpStack (v4) is recommended,
in some use-cases a REST API cna be more convenient. It could also help when
migrating from ChirpStack v3 to v4 as previously this proxy was embedded inside
the ChirpStack Application Server.

## Usage

```bash
chirpstack-rest-api --server localhost:8080 --bind 0.0.0.0:8090 --insecure --cors "*"
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
* `--cors` defines the CORS policy by setting the AllowedOrigins Header. You can also use the environment variable `CORS`. `--cors "*"` allows all origins. Default is `--cors 0.0.0.0` which disables CORS.

## Debian / Ubuntu

### Add ChirpStack repository

Add the ChirpStack repository as described in the [Documentation](https://www.chirpstack.io/docs/chirpstack/downloads.html#debian--ubuntu-repository).

### Install package

After you have added the ChirpStack repository, you can install this component
using the following command:

```bash
sudo apt install chirpstack-rest-api
```

### Configuration

Environment variables can be used to configure the ChirpStack REST API proxy.
You will find this configuration in `/etc/chirpstack-rest-api/environment`.

### (Re)start and stop

```bash
sudo systemctl [restart|start|stop] chirpstack-rest-api
```

## Downloads

Please refer to: [https://artifacts.chirpstack.io/downloads/chirpstack-rest-api/](https://artifacts.chirpstack.io/downloads/chirpstack-rest-api/).

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
