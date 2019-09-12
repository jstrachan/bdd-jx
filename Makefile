NAME := bdd-jx
GO := GO111MODULE=on go

PACKAGE_DIRS = $(shell $(GO) list ./test/...)

BUILDFLAGS :=

TESTFLAGS ?= -v -timeout 60m
TESTSUFFIXFLAGS ?= -ginkgo.v

ifdef DEBUG
BUILDFLAGS += -gcflags "all=-N -l" $(BUILDFLAGS)
endif


all: build

check: fmt

fmt:
	@FORMATTED=`$(GO) fmt $(PACKAGE_DIRS)`
	@([[ ! -z "$(FORMATTED)" ]] && printf "Fixed unformatted files:\n$(FORMATTED)") || true

clean:
	rm -rf build

build:
	$(GO) build $(BUILDFLAGS) ./test/...

.PHONY: clean test build fmt

### LEGACY TARGETS, use go test when running locally ###

install:
	echo "deprecated"

test-import:
	$(GO) test $(TESTFLAGS) ./test/suite/_import $(TESTSUFFIXFLAGS)

test-app-lifecycle:
	$(GO) test $(TESTFLAGS) ./test/suite/apps $(TESTSUFFIXFLAGS)

test-verify-pods:
	$(GO) test $(TESTFLAGS) ./test/suite/step $(TESTSUFFIXFLAGS)

test-create-spring:
	$(GO) test $(TESTFLAGS) ./test/suite/spring $(TESTSUFFIXFLAGS)

test-upgrade-ingress:
	$(GO) test $(TESTFLAGS) ./test/suite/ingress $(TESTSUFFIXFLAGS)

test-upgrade-platform:
	$(GO) test $(TESTFLAGS) ./test/suite/platform $(TESTSUFFIXFLAGS)

test-supported-quickstarts:
	JX_BDD_QUICKSTARTS= $(GO) test $(TESTFLAGS) ./test/suite/quickstart -ginkgo.focus=(node-http|spring-boot-http-gradle|golang-http) $(TESTSUFFIXFLAGS)

test-devpod:
	$(GO) test $(TESTFLAGS) ./test/suite/devpods $(TESTSUFFIXFLAGS)

#targets for individual quickstarts
test-quickstart-golang-http:
	$(GO) test $(TESTFLAGS) ./test/suite/quickstart -ginkgo.focus=golang-http $(TESTSUFFIXFLAGS)

bdd-init:
	echo "About to run the BDD tests on the current cluster"
	git config --global credential.helper store
	git config --global --add user.name jenkins-x-bot
	git config --global --add user.email jenkins-x@googlegroups.com
	jx step git validate
	jx step git credentials
	ls -al ~
	cat ~/.gitconfig

bdd: bdd-init test-create-spring

