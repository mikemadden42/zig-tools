// zig build-exe tidy.zig -O ReleaseFast

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    var buf: [4096]u8 = undefined;

    if (args.len != 1) {
        var stderr = std.Io.File.stderr().writer(init.io, &buf);
        try stderr.interface.print("Usage: {s}\n", .{args[0]});
        try stderr.interface.flush();
        std.process.exit(1);
    }

    const io = init.io;
    const allocator = init.gpa;

    const stdout = std.Io.File.stdout();
    var writer_wrapper = stdout.writer(init.io, &buf);
    var writer = &writer_wrapper.interface;

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

            dir.createDirPath(io, d) catch |err| {
                try writer.print("Error creating directory {s}: {}\n", .{ d, err });
                continue;
            };

            const new_path = std.fs.path.join(allocator, &[_][]const u8{ d, entry.name }) catch |err| {
                try writer.print("Error preparing path for {s}: {}\n", .{ entry.name, err });
                continue;
            };
            defer allocator.free(new_path);

            try writer.print("Attempting to move {s} to {s}\n", .{ entry.name, new_path });
            dir.rename(entry.name, dir, new_path, io) catch |err| {
                try writer.print("Error moving {s}: {}\n", .{ entry.name, err });
                continue;
            };
            try writer.print("Successfully moved {s} to {s}\n", .{ entry.name, new_path });
        } else {
            try writer.print("No date pattern found in: {s}\n", .{entry.name});
        }
    }
    try writer.flush();
}
