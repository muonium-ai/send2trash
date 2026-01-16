# Copyright (c) 2026 Senthil Nayagam

SWIFT_BUILD?=swift build
SWIFT_RUN?=swift run
PREFIX?=/usr/local
BIN_DIR?=$(PREFIX)/bin
BUILD_OUTPUT?=.build/release/send2trash

.PHONY: all build run install test smoke-test docs clean

all: build

build:
	$(SWIFT_BUILD)

run:
	$(SWIFT_RUN) send2trash

install:
	$(SWIFT_BUILD) -c release
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
