
ORG := github.com/hans-d
PROJECT := echo-server
REGISTRY ?= docker.pkg.github.com

VERSION_MAJOR ?= 0
VERSION_MINOR ?= 0
VERSION_BUILD ?= 0

GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)



REPOPATH ?= $(ORG)/$(PROJECT)
VERSION ?= v$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_BUILD)

VERSION_PACKAGE = $(REPOPATH)/pkg/version



GO_FILES := $(shell find . -type f -name '*.go' -not -path "./vendor/*")
GO_LDFLAGS := '-extldflags "-static"
GO_LDFLAGS += -X $(VERSION_PACKAGE).version=$(VERSION)
GO_LDFLAGS += -w -s # Drop debugging symbols.
GO_LDFLAGS += '


CMD_PACKAGES := $(shell find cmd -type d -mindepth 1 -maxdepth 1)



default:

compile: out/http-echo

out/http-echo: $(GO_FILES)
	GOARCH=$(GOARCH) GOOS=linux CGO_ENABLED=0 go build -ldflags $(GO_LDFLAGS) -o $@ $(subst out,$(REPOPATH)/cmd,$@)

image:
	docker build ${BUILD_ARG} --build-arg=GOARCH=$(GOARCH) -t $(REGISTRY)/$(PROJECT):latest -f Dockerfile .
