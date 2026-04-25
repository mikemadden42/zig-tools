# zig-tools

A collection of small command-line utilities written in Zig for everyday file management and utility tasks.

## Tools

- **hello** - Simple "Hello, world!" program
- **tidy** - Organizes files by extracting YYYY-MM-DD dates from filenames and moving them into date-named subdirectories
- **cal** - Calendar generator that displays a formatted monthly calendar (accepts month/year arguments or uses current date)
- **goodpass** - Secure password generator using cryptographic random number generation
- **prunedir** - File organizer that sorts files by extension into `Documents/<extension>/` subdirectories

## Building

```bash
# Build all tools
make all

# Build a specific tool
make cal

# Format all source files
make fmt

# Clean build artifacts
make clean
```