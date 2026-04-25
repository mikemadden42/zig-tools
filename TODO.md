# TODO

## Improvements & Bug Fixes

- [ ] **`tidy.zig`**: Handle filenames with multiple date patterns. Currently,
  it only processes the first match.
- [ ] **`cal.zig`**: Consider local timezone for the current date calculation.
  The current implementation uses UTC (`.real`), which may be off by a day/month
  depending on the user's location.
- [ ] **`cal.zig`**: The header padding calculation might need adjustment for
  very short/long month names to ensure perfect centering.

## Completed

- [x] **`prunedir.zig`** & **`tidy.zig`**: Improved error handling to log and
  continue instead of terminating.
- [x] **`goodpass.zig`**: Added validation for the `length` argument.
- [x] **`cal.zig`**: Hardened input parsing and added month/year validation.
- [x] **Project**: Unified I/O and entry points across all tools.
- [x] **Project**: Added `install` and `test` targets to `Makefile`.
