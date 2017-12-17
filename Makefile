NAME := hello
VERSION := $(shell git describe --tags --abbrev=0)
REVISION := $(shell git rev-parse --short HEAD)
LDFLAGS := -x 'main.version=$(VERSION)' \
	-x 'main.revision=$(REVISION)'

setup:
	go get github.com/golang/dep/cmd/dep
	go get github.com/golang/lint/golint
	go get golang.org/x/tools/cmd/goimports

test: deps
	go test ./...

deps: setup
	dep ensure

lint: setup
	go vet ./...
	# TODO: Replace with "./..." after https://github.com/golang/lint/pull/325
	git ls-files | grep "\.go" | xargs golint -set_exit_status || exit $$?

format: setup
	goimports -w $$(git ls-files --modified | grep "\.go")

bin/%: cmd/%/main.go deps
	go build -ldflags "$(LDFLAGS)" -o $@ $<

.PHONY: setup test deps lint format
