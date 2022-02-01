# Build

FROM golang:1.17 AS build
ARG TARGETARCH

ENV GOARCH=$TARGETARCH
ENV CGO_ENABLED=0
ENV GOBIN=/usr/local/bin

WORKDIR /src

COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg \
    make compile GOARCH=$TARGETARCH

# Final

FROM scratch

COPY --from=build /src/out/* /bin/.
ENV PATH /bin
ENV PORT 8080
WORKDIR /workspace

CMD ["/bin/"]
