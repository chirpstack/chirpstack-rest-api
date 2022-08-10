.PHONY: build dev-requirements devshell
BUILD_VERSION := $(shell git describe --always |sed -e "s/^v//")

GW_GEN := protoc -I=/googleapis -I=chirpstack/api/proto --grpc-gateway_out=paths=source_relative,logtostderr=true:.
API_GEN := protoc -I=/googleapis -I=chirpstack/api/proto --openapiv2_out ./openapiv2 --openapiv2_opt logtostderr=true
GRPC_GEN := protoc -I=/googleapis -I=chirpstack/api/proto --go_out=. --go_opt=paths=source_relative --go-grpc_out=. --go-grpc_opt=paths=source_relative

build:
	mkdir -p build
	go build $(GO_EXTRA_BUILD_ARGS) -ldflags "-s -w -X main.version=$(BUILD_VERSION)" -o build/chirpstack-rest-api main.go

dist:
	goreleaser
	mkdir -p dist/upload
	mv dist/*.tar.gz dist/upload
	mv dist/*.deb dist/upload
	mv dist/*.rpm dist/upload

snapshot:
	goreleaser --snapshot

dev-requirements:
	git submodule update --init
	go mod download
	go install google.golang.org/protobuf/cmd/protoc-gen-go
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2
	go install github.com/goreleaser/goreleaser@latest
	go install github.com/goreleaser/nfpm/v2/cmd/nfpm

devshell:
	docker-compose run --rm chirpstack-rest-api bash

generate:
	cd chirpstack && git fetch && git checkout ${VERSION}
	${GW_GEN} api/application.proto
	${GW_GEN} api/device.proto
	${GW_GEN} api/device_profile.proto
	${GW_GEN} api/device_profile_template.proto
	${GW_GEN} api/gateway.proto
	${GW_GEN} api/multicast_group.proto
	${GW_GEN} api/tenant.proto
	${GW_GEN} api/user.proto

	${GRPC_GEN} api/application.proto
	${GRPC_GEN} api/device.proto
	${GRPC_GEN} api/device_profile.proto
	${GRPC_GEN} api/device_profile_template.proto
	${GRPC_GEN} api/gateway.proto
	${GRPC_GEN} api/multicast_group.proto
	${GRPC_GEN} api/tenant.proto
	${GRPC_GEN} api/user.proto

	${API_GEN} api/application.proto
	${API_GEN} api/device.proto
	${API_GEN} api/device_profile.proto
	${API_GEN} api/device_profile_template.proto
	${API_GEN} api/gateway.proto
	${API_GEN} api/multicast_group.proto
	${API_GEN} api/tenant.proto
	${API_GEN} api/user.proto

	cd ui && go run merge.go ${VERSION} ../openapiv2/api > api.json
