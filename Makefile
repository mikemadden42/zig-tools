# List all source files
SOURCES := $(wildcard *.zig)
# Create binary names by removing .zig extension
BINARIES := $(SOURCES:.zig=)
# Create object file names from binary names
OBJECTS := $(BINARIES:%=%.o)

# Installation prefix
PREFIX ?= /usr/local

# Default zig build flags (can be overridden)
ZIGFLAGS := -O ReleaseFast -fstrip

.PHONY: all clean fmt install

# Default target to build all binaries
all: $(BINARIES)

# Pattern rule to build each binary from its source
%: %.zig
	zig build-exe $< $(ZIGFLAGS) -femit-bin=$@

# Format all Zig source files
fmt:
	zig fmt --ast-check --color auto $(SOURCES)

# Install binaries to PREFIX/bin
install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp $(BINARIES) $(DESTDIR)$(PREFIX)/bin

# Clean target to remove all binaries
clean:
	rm -f $(BINARIES)
	rm -f $(OBJECTS)
