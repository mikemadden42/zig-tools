# List all source files
SOURCES := $(wildcard *.zig)
# Create binary names by removing .zig extension
BINARIES := $(SOURCES:.zig=)
# Create object file names from binary names
OBJECTS := $(BINARIES:%=%.o)

# Default zig build flags (can be overridden)
#ZIGFLAGS := -O Debug
#ZIGFLAGS := -O ReleaseSafe
#ZIGFLAGS := -O ReleaseFast
ZIGFLAGS := -O ReleaseFast -fstrip
#ZIGFLAGS := -O ReleaseSmall

.PHONY: all clean

# Default target to build all binaries
all: $(BINARIES)

# Pattern rule to build each binary from its source
%: %.zig
	zig build-exe $< $(ZIGFLAGS) -femit-bin=$@

# Format all Zig source files
fmt:
	zig fmt --ast-check --color auto $(SOURCES)
	#zig fmt $(SOURCES)

# Clean target to remove all binaries
clean:
	rm -f $(BINARIES)
	rm -f $(OBJECTS)
