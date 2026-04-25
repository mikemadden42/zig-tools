const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const stdout = std.Io.File.stdout();
    var buf: [4096]u8 = undefined;
    var writer = stdout.writer(init.io, &buf);

    const args = try init.minimal.args.toSlice(init.arena.allocator());

    if (args.len != 2) {
        var stderr = std.Io.File.stderr().writer(init.io, &buf);
        try stderr.interface.print("Usage: {s} <password_length>\n", .{args[0]});
        try stderr.interface.flush();
        std.process.exit(1);
    }

    const length = try std.fmt.parseInt(usize, args[1], 10);
    if (length == 0 or length > 1024) {
        var stderr = std.Io.File.stderr().writer(init.io, &buf);
        try stderr.interface.writeAll("Error: length must be between 1 and 1024\n");
        try stderr.interface.flush();
        std.process.exit(1);
    }
    const password = try generatePassword(init.gpa, init.io, length);
    defer init.gpa.free(password);

    try writer.interface.print("Generated password: {s}\n", .{password});
    try writer.interface.flush();
}

fn generatePassword(allocator: std.mem.Allocator, io: std.Io, length: usize) ![]u8 {
    const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+";
    const password = try allocator.alloc(u8, length);

    var rand = (std.Random.IoSource{ .io = io }).interface();

    for (password) |*c| {
        c.* = charset[rand.uintLessThan(u8, charset.len)];
    }

    return password;
}
