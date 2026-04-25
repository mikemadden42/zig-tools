const std = @import("std");
const mem = std.mem;

pub fn clean(init: std.process.Init, writer: anytype) !void {
    const cwd = std.Io.Dir.cwd();
    const io = init.io;
    const allocator = init.gpa;

    var dir = try cwd.openDir(io, ".", .{ .iterate = true });
    defer dir.close(io);

    var iter = dir.iterate();
    while (try iter.next(io)) |entry| {
        if (entry.kind != .file) continue;

        const file_name = entry.name;

        if (mem.lastIndexOf(u8, file_name, ".")) |dot_index| {
            const extension = file_name[dot_index + 1 ..];

            const dest_dir_path = try std.fmt.allocPrint(allocator, "Documents/{s}", .{extension});
            defer allocator.free(dest_dir_path);

            try cwd.createDirPath(io, dest_dir_path);

            const dest_path = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ dest_dir_path, file_name });
            defer allocator.free(dest_path);

            if (cwd.access(io, dest_path, .{})) |_| {
                try writer.print("File {s} already exists in {s}\n", .{ file_name, dest_dir_path });
            } else |_| {
                try cwd.rename(file_name, cwd, dest_path, io);
                try writer.print("Moved {s} to {s}\n", .{ file_name, dest_dir_path });
            }
        }
    }
}

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    var buf: [4096]u8 = undefined;

    if (args.len != 1) {
        var stderr = std.Io.File.stderr().writer(init.io, &buf);
        try stderr.interface.print("Usage: {s}\n", .{args[0]});
        try stderr.interface.flush();
        std.process.exit(1);
    }

    const stdout = std.Io.File.stdout();
    var writer = stdout.writer(init.io, &buf);

    try clean(init, &writer.interface);
    try writer.interface.flush();
}

