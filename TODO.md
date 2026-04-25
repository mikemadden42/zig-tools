# TODO

## Improvements & Bug Fixes

- [ ] **`tidy.zig`**: Handle filenames with multiple date patterns. Currently,
  it only processes the first match.
- [ ] **`prunedir.zig`**: Improve error handling in the `clean` function. If
  `createDirPath` or `rename` fails for a single file, it should ideally log the
  error and continue to the next file instead of terminating.
- [ ] **`goodpass.zig`**: Add validation for the `length` argument (e.g., ensure
  it's greater than 0 and within a reasonable upper bound to prevent allocation
  issues).
- [ ] **`cal.zig`**: Consider local timezone for the current date calculation.
  The current implementation uses UTC (`.real`), which may be off by a day/month
  depending on the user's location.
- [ ] **`cal.zig`**: The header padding calculation might need adjustment for
  very short/long month names to ensure perfect centering.
