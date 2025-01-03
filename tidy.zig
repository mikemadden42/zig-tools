// zig build-exe tidy.zig -O ReleaseFast

const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const print = std.debug.print;

pub fn main() !void {
    const directory = ".";

    var dir = try fs.cwd().openDir(directory, .{ .iterate = true });
    defer dir.close();

    var it = dir.iterate();
    while (try it.next()) |entry| {
        print("Processing file: {s}\n", .{entry.name});

        if (entry.kind == .directory) {
            print("Skipping directory: {s}\n", .{entry.name});
            continue;
        }

        // Look for the date pattern YYYY-MM-DD
        if (std.mem.indexOf(u8, entry.name, "202")) |year_start| {
            if (year_start + 10 <= entry.name.len) {
                const potential_date = entry.name[year_start .. year_start + 10];
                print("Potential date found: {s}\n", .{potential_date});

                if (potential_date.len == 10 and
                    std.fmt.parseInt(u32, potential_date[0..4], 10) catch null != null and
                    potential_date[4] == '-' and
                    std.fmt.parseInt(u8, potential_date[5..7], 10) catch null != null and
                    potential_date[7] == '-' and
                    std.fmt.parseInt(u8, potential_date[8..10], 10) catch null != null)
                {
                    const date = potential_date;
                    print("Valid date found: {s}\n", .{date});

                    try dir.makePath(date);

                    const new_path = try fs.path.join(std.heap.page_allocator, &[_][]const u8{ date, entry.name });
                    defer std.heap.page_allocator.free(new_path);

                    print("Attempting to move {s} to {s}\n", .{ entry.name, new_path });
                    try dir.rename(entry.name, new_path);
                    print("Successfully moved {s} to {s}\n", .{ entry.name, new_path });
                } else {
                    print("Invalid date format: {s}\n", .{potential_date});
                }
            } else {
                print("Filename too short to contain a valid date\n", .{});
            }
        } else {
            print("No date pattern found in: {s}\n", .{entry.name});
        }
    }

    print("Files have been organized by date.\n", .{});
}
