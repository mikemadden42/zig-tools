const std = @import("std");
const mem = std.mem;
const print = std.debug.print;

pub fn clean(allocator: std.mem.Allocator, io: std.Io) !void {
    const cwd = std.Io.Dir.cwd();

    var dir = try cwd.openDir(io, ".", .{ .iterate = true });
    defer dir.close(io);

    var iter = dir.iterate();
    while (try iter.next(io)) |entry| {
        if (entry.kind != .file) continue;

        const file_name = entry.name;
        if (file_name[0] == '.') continue; // Skip dotfiles

        if (mem.lastIndexOf(u8, file_name, ".")) |dot_index| {
            const extension = file_name[dot_index + 1 ..];

            const dest_dir_path = try std.fmt.allocPrint(allocator, "Documents/{s}", .{extension});
            defer allocator.free(dest_dir_path);

            try cwd.createDirPath(io, dest_dir_path);

            const dest_path = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ dest_dir_path, file_name });
            defer allocator.free(dest_path);

            if (cwd.access(io, dest_path, .{})) |_| {
                print("File {s} already exists in {s}\n", .{ file_name, dest_dir_path });
            } else |_| {
                try cwd.rename(file_name, cwd, dest_path, io);
                print("Moved {s} to {s}\n", .{ file_name, dest_dir_path });
            }
        }
    }
}

pub fn main(init: std.process.Init) !void {
    try clean(init.gpa, init.io);
}
