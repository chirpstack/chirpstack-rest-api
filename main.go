package main

import (
	"context"
	"crypto/tls"
	"flag"
	"net/http"
	"os"

	"github.com/gorilla/mux"
	"github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/credentials/insecure"

	gw "github.com/chirpstack/chirpstack-rest-api/api"
	"github.com/chirpstack/chirpstack-rest-api/ui"
)

var (
	server = flag.String("server", envString("SERVER", "localhost:8080"), "ChirpStack API endpoint")
	bind   = flag.String("bind", envString("BIND", "0.0.0.0:8090"), "REST API server bind")
	insec  = flag.Bool("insecure", envBool("INSECURE", false), "Use insecure (non-TLS) connection to server")
)

func envString(key string, defVal string) string {
	if val, ok := os.LookupEnv(key); ok {
		return val
	}
	return defVal
}

func envBool(key string, defVal bool) bool {
	if _, ok := os.LookupEnv(key); ok {
		return true
	}
	return defVal
}

func run() error {
	ctx := context.Background()
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	r := mux.NewRouter()
	gatewayHandler, err := getGatewayHandler(ctx)
	if err != nil {
		return err
	}

	r.PathPrefix("/api/").Handler(gatewayHandler)
	r.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		data, err := ui.FS.ReadFile("index.html")
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		w.Write(data)
	})
	r.PathPrefix("/").Handler(http.FileServer(http.FS(ui.FS)))

	return http.ListenAndServe(*bind, r)
}

func getGatewayHandler(ctx context.Context) (http.Handler, error) {
	mux := runtime.NewServeMux()
	opts := []grpc.DialOption{}

	if *insec {
		opts = append(opts, grpc.WithTransportCredentials(insecure.NewCredentials()))
	} else {
		opts = append(opts, grpc.WithTransportCredentials(credentials.NewTLS(&tls.Config{})))
	}

	if err := gw.RegisterApplicationServiceHandlerFromEndpoint(ctx, mux, *server, opts); err != nil {
		return nil, err
	}
	if err := gw.RegisterDeviceServiceHandlerFromEndpoint(ctx, mux, *server, opts); err != nil {
		return nil, err
	}
	if err := gw.RegisterDeviceProfileServiceHandlerFromEndpoint(ctx, mux, *server, opts); err != nil {
		return nil, err
	}
	if err := gw.RegisterDeviceProfileTemplateServiceHandlerFromEndpoint(ctx, mux, *server, opts); err != nil {
		return nil, err
	}
	if err := gw.RegisterGatewayServiceHandlerFromEndpoint(ctx, mux, *server, opts); err != nil {
		return nil, err
	}
	if err := gw.RegisterMulticastGroupServiceHandlerFromEndpoint(ctx, mux, *server, opts); err != nil {
		return nil, err
	}
	if err := gw.RegisterTenantServiceHandlerFromEndpoint(ctx, mux, *server, opts); err != nil {
		return nil, err
	}
	if err := gw.RegisterUserServiceHandlerFromEndpoint(ctx, mux, *server, opts); err != nil {
		return nil, err
	}

	return mux, nil
}

func main() {
	flag.Parse()

	if err := run(); err != nil {
		panic(err)
	}
}
