const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const print = std.debug.print;

pub fn clean() !void {
    var dir = try fs.cwd().openDir(".", .{ .iterate = true });
    defer dir.close();

    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind != .file) continue;

        const file_name = entry.name;
        if (file_name[0] == '.') continue; // Skip dotfiles

        if (mem.lastIndexOf(u8, file_name, ".")) |dot_index| {
            const extension = file_name[dot_index + 1 ..];
            if (mem.eql(u8, extension, "9")) continue;

            const dest_dir_path = try std.fmt.allocPrint(std.heap.page_allocator, "Documents/{s}", .{extension});
            defer std.heap.page_allocator.free(dest_dir_path);

            try fs.cwd().makePath(dest_dir_path);

            const dest_path = try std.fmt.allocPrint(std.heap.page_allocator, "{s}/{s}", .{ dest_dir_path, file_name });
            defer std.heap.page_allocator.free(dest_path);

            if (fs.cwd().access(dest_path, .{})) |_| {
                print("File {s} already exists in {s}\n", .{ file_name, dest_dir_path });
            } else |_| {
                try fs.cwd().rename(file_name, dest_path);
                print("Moved {s} to {s}\n", .{ file_name, dest_dir_path });
            }
        }
    }
}

pub fn main() !void {
    clean() catch |err| {
        print("Error: {}\n", .{err});
        return err;
    };
}
