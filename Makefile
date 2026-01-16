
SWIFT_BUILD?=swift build
SWIFT_RUN?=swift run

.PHONY: all build run clean

all: build

build:
	$(SWIFT_BUILD)

run:
	$(SWIFT_RUN) trash

clean:
	swift package clean
