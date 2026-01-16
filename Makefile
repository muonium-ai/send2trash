# Copyright (c) 2026 Senthil Nayagam

SWIFT_BUILD?=swift build
SWIFT_RUN?=swift run
PREFIX?=/usr/local
BIN_DIR?=$(PREFIX)/bin
BUILD_OUTPUT?=.build/release/send2trash

# SwiftPM uses sandbox-exec on macOS for manifest evaluation/plugins.
# In some environments (notably when the parent process is sandboxed),
# sandbox-exec can fail with "sandbox_apply: Operation not permitted".
# Homebrew already sandboxes builds, so we disable SwiftPM's sandbox when
# building under Homebrew.
SWIFT_BUILD_FLAGS?=
ifneq ($(HOMEBREW_PREFIX),)
SWIFT_BUILD_FLAGS+=--disable-sandbox
endif

# Homebrew invokes `make install PREFIX=/opt/homebrew/Cellar/...`.
# Some environments don't export HOMEBREW_PREFIX into the build, so also
# detect Homebrew via the install PREFIX.
ifneq (,$(findstring /Cellar/,$(PREFIX)))
SWIFT_BUILD_FLAGS+=--disable-sandbox
endif

.PHONY: all build run install test smoke-test docs clean

all: build

build:
	$(SWIFT_BUILD) $(SWIFT_BUILD_FLAGS)

run:
	$(SWIFT_RUN) send2trash

install:
	$(SWIFT_BUILD) -c release $(SWIFT_BUILD_FLAGS)
	install -d "$(BIN_DIR)"
	install "$(BUILD_OUTPUT)" "$(BIN_DIR)/send2trash"

test:
	swift test

smoke-test:
	TRASH_INTEGRATION=1 swift test

docs:
	pod2man --section=1 --center="send2trash" --date="$(shell date +"%Y-%m-%d")" trash.pod > send2trash.1

clean:
	swift package clean
