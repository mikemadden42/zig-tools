// zig build-exe tidy.zig -O ReleaseFast

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;

    const stdout = std.Io.File.stdout();
    var buf: [4096]u8 = undefined;
    var writer = (stdout.writer(init.io, &buf)).interface;

    var dir = std.Io.Dir.cwd().openDir(io, ".", .{ .iterate = true }) catch |err| {
        try writer.print("Error opening directory: {}\n", .{err});
        try writer.flush();
        return err;
    };
    defer dir.close(io);

    var it = dir.iterate();
    while (try it.next(io)) |entry| {
        try writer.print("Processing file: {s}\n", .{entry.name});

        if (entry.kind == .directory) {
            try writer.writeAll("Skipping directory\n");
            continue;
        }

        // Look for the date pattern YYYY-MM-DD
        var year_start: usize = 0;
        const date: ?[]const u8 = blk: {
            while (year_start + 10 <= entry.name.len) : (year_start += 1) {
                const potential_date = entry.name[year_start .. year_start + 10];
                const yr = std.fmt.parseInt(u32, potential_date[0..4], 10) catch continue;
                if (yr < 1000) continue;
                if (potential_date[4] != '-') continue;
                _ = std.fmt.parseInt(u8, potential_date[5..7], 10) catch continue;
                if (potential_date[7] != '-') continue;
                _ = std.fmt.parseInt(u8, potential_date[8..10], 10) catch continue;
                break :blk potential_date;
            }
            break :blk null;
        };

        if (date) |d| {
            try writer.print("Valid date found: {s}\n", .{d});

            try dir.createDirPath(io, d);

            const new_path = try std.fs.path.join(allocator, &[_][]const u8{ d, entry.name });
            defer allocator.free(new_path);

            try writer.print("Attempting to move {s} to {s}\n", .{ entry.name, new_path });
            try dir.rename(entry.name, dir, new_path, io);
            try writer.print("Successfully moved {s} to {s}\n", .{ entry.name, new_path });
        } else {
            try writer.print("No date pattern found in: {s}\n", .{entry.name});
        }
    }
    try writer.flush();
}
