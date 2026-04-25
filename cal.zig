const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const stdout = std.Io.File.stdout();
    var buf: [4096]u8 = undefined;
    var writer = stdout.writer(init.io, &buf);

    const args = try init.minimal.args.toSlice(init.arena.allocator());

    var year: u16 = undefined;
    var month: u4 = undefined;

    if (args.len == 3) {
        month = try std.fmt.parseInt(u4, args[1], 10);
        year = try std.fmt.parseInt(u16, args[2], 10);
    } else if (args.len == 1) {
        const now = std.Io.Timestamp.now(init.io, .real);
        const secs: u64 = @intCast(now.toSeconds());
        const epoch_seconds = std.time.epoch.EpochSeconds{ .secs = secs };
        const year_day = epoch_seconds.getEpochDay().calculateYearDay();
        const month_day = year_day.calculateMonthDay();
        year = year_day.year;
        month = @intCast(@intFromEnum(month_day.month));
    } else {
        var stderr = std.Io.File.stderr().writer(init.io, &buf);
        try stderr.interface.print("Usage: {s} [month year]\n", .{args[0]});
        try stderr.interface.flush();
        std.process.exit(1);
    }

    try printCalendar(&writer.interface, year, month);
    try writer.interface.flush();
}

fn printCalendar(writer: *std.Io.Writer, year: u16, month: u4) !void {
    const monthName = [_][]const u8{ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" };
    const daysInMonth = [_]u5{ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

    // Create header string
    var headerBuf: [32]u8 = undefined;
    const header = try std.fmt.bufPrint(&headerBuf, "{s} {}", .{ monthName[month - 1], year });

    // Calculate padding for centering (total width is 20)
    const leftPadding = (20 - header.len) / 2;
    const rightPadding = 20 - header.len - leftPadding;

    // Print centered header
    try writer.splatByteAll(' ', leftPadding);
    try writer.writeAll(header);
    try writer.splatByteAll(' ', rightPadding + 2);
    try writer.writeByte('\n');

    try writer.writeAll("Su Mo Tu We Th Fr Sa  \n");

    const firstDayOfMonth = calculateDayOfWeek(year, month, 1);

    // Print leading spaces
    var i: u32 = 0;
    while (i < firstDayOfMonth) : (i += 1) {
        try writer.writeAll("   ");
    }

    const days = if (month == 2 and isLeapYear(year)) 29 else daysInMonth[month - 1];
    var day: u32 = 1;
    var weekDay: u32 = firstDayOfMonth;

    while (day <= days) : (day += 1) {
        if (weekDay == 6) {
            try writer.print("{d:2}  \n", .{day});
        } else if (day == days) {
            const remainingSpaces = (6 - weekDay) * 3 + 2;
            try writer.print("{d:2}", .{day});
            try writer.splatByteAll(' ', remainingSpaces);
            try writer.writeByte('\n');
        } else {
            try writer.print("{d:2} ", .{day});
        }
        weekDay = (weekDay + 1) % 7;
    }

    // Add final empty line with 22 spaces
    try writer.splatByteAll(' ', 22);
    try writer.writeByte('\n');
}

fn calculateDayOfWeek(year: u16, month: u4, day: u5) u3 {
    const t = [_]u8{ 0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4 };
    var y = year;
    if (month < 3) y -= 1;
    const result = (y + y / 4 - y / 100 + y / 400 + t[month - 1] + day) % 7;
    return @intCast(result);
}

fn isLeapYear(year: u16) bool {
    return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0);
}
