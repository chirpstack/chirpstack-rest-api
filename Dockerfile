FROM golang:1.18-alpine AS development

ENV PROJECT_PATH=/chirpstack-rest-api
ENV PATH=$PATH:$PROJECT_PATH/build
ENV CGO_ENABLED=0
ENV GO_EXTRA_BUILD_ARGS="-a -installsuffix cgo"

RUN apk add --no-cache ca-certificates make git bash

RUN mkdir -p $PROJECT_PATH
COPY . $PROJECT_PATH
WORKDIR $PROJECT_PATH

RUN make dev-requirements
RUN make

FROM alpine:3.15.0 AS production

RUN apk --no-cache add ca-certificates
COPY --from=development /chirpstack-rest-api/build/chirpstack-rest-api /usr/bin/chirpstack-rest-api
USER nobody:nogroup
ENTRYPOINT ["/usr/bin/chirpstack-rest-api"]
