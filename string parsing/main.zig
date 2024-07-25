const std = @import("std");

pub fn main() !void {
    const filename = "num.txt";

    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const readFile = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(readFile);

    var iterate = std.mem.tokenizeAny(u8, readFile, "\n");
    var count: u32 = 0;
    while (iterate.next()) |content| {
        const seperator = std.mem.indexOfScalar(u8, content, ',') orelse {
            std.debug.print("Invalid line format: {s}\n", .{content});
            continue;
        };

        const f1 = parseRange(content[0..seperator]) catch |err| {
            std.debug.print("Error parsing first range: {s}, error: {}\n", .{ content[0..seperator], err });
            continue;
        };
        const f2 = parseRange(content[seperator + 1 ..]) catch |err| {
            std.debug.print("Error parsing second range: {s}, error: {}\n", .{ content[seperator + 1 ..], err });
            continue;
        };

        const found = isFound(f1, f2);
        if (found) count += 1;

        std.debug.print("{} : {} is found: {}\n", .{ f1, f2, found });
    }
    std.debug.print("the total count {}\n", .{count});
}

const ERange = struct { low: u8, high: u8 };

fn parseTypes(v: []const u8) !u8 {
    return std.fmt.parseInt(u8, v, 10);
}

fn parseRange(r: []const u8) !ERange {
    const sep = std.mem.indexOfScalar(u8, r, '-') orelse return error.InvalidFormat;
    const low = try parseTypes(r[0..sep]);
    const high = try parseTypes(r[sep + 1 ..]);
    return .{ .low = low, .high = high };
}

fn isFound(r1: ERange, r2: ERange) bool {
    const t1 = r1.low <= r2.low and r1.high >= r2.high;
    const t2 = r2.low <= r1.low and r2.high >= r1.high;

    return t1 or t2;
}
