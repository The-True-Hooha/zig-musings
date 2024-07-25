const std = @import("std");

fn findIdenticalKey(content: []const u8, allocator: std.mem.Allocator) !u8 {
    const get_half = content.len / 2;

    const first_part = content[0..get_half];
    const second_part = content[get_half..];
    // std.debug.print("the first part {c}\n the second part{c}\n", .{ first_part, second_part });

    // create a hashmap
    var map = std.AutoHashMap(u8, void).init(allocator);
    defer map.deinit();

    for (first_part) |i| {
        const r = try map.getOrPut(i);
        if (!r.found_existing) {
            r.value_ptr.* = {};
        }
    }

    for (second_part) |k| {
        if (map.contains(k)) {
            return k;
        }
    }

    return undefined;
}

fn getCharPriority(char: u8) u32 {
    return if (char >= 'a') char - 'a' + 1 else char - 'A' + 27;
}

pub fn main() !void {
    std.debug.print("day 3 third project \n", .{});
    const filename = "file.txt";

    std.debug.print("{s}\n", .{filename});

    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

    defer arena.deinit();

    const allocator = arena.allocator();

    const read_file = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(read_file);

    // try std.io.getStdOut().writeAll(read_file); // write out the contents of the file

    var iterate_through_file = std.mem.tokenizeAny(u8, read_file, "\n");

    var sum: u32 = 0;

    while (iterate_through_file.next()) |content| {
        // std.debug.print("printing the file {any}\n", .{content});
        const char = try findIdenticalKey(content, allocator);
        sum += char;
        std.debug.print("found the comon key: {c}\n", .{char});
        std.debug.print("the priority are {any}\n", .{getCharPriority(char)});
        std.debug.print("Total sum: {}\n", .{sum});
    }
}
