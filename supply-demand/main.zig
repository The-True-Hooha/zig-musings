const std = @import("std");

const Stack = std.ArrayList(u8);

const Operation = struct { from: u8, to: u8, number: u8 };

pub fn create_stacks(allocator: std.mem.Allocator, stack_count: u8, it: *std.mem.SplitBackwardsIterator(u8, .any)) ![]Stack {
    var stacks: []Stack = try allocator.alloc(Stack, stack_count);
    for (stacks, 0..) |_, i| {
        stacks[i] = Stack.init(allocator);
    }

    while (it.next()) |line| {
        if (line.len == 0) continue;
        var i: usize = 0;
        while (i < stack_count) : (i += 1) {
            const index = i * 4 + 1;
            const item = line[index];
            // std.debug.print("{c}", .{item});
            if (item != ' ') {
                try stacks[i].append(item);
            }
        }
    }

    return stacks;
}

pub fn create_operations(allocator: std.mem.Allocator, operations_input: []const u8) ![]Operation {
    var operations = std.ArrayList(Operation).init(allocator);
    var it = std.mem.splitAny(u8, operations_input, "\n");

    while (it.next()) |line| {
        var line_iterator = std.mem.splitAny(u8, line, " ");
        _ = line_iterator.next().?; // not using it
        const move_stacks_count = try std.fmt.parseInt(u8, line_iterator.next().?, 10);
        _ = line_iterator.next().?; // not using it
        const from_stacks_index = try std.fmt.parseInt(u8, line_iterator.next().?, 10);
        _ = line_iterator.next().?; // not using it
        const to_stacks_index = try std.fmt.parseInt(u8, line_iterator.next().?, 10);
        try operations.append(.{ .number = move_stacks_count, .from = from_stacks_index - 1, .to = to_stacks_index - 1 });
    }
    return operations.toOwnedSlice();
}

const Solver = struct {
    allocator: std.mem.Allocator,
    stacks: []Stack,
    operations: []Operation,

    pub fn init(allocator: std.mem.Allocator, input: []const u8) !Solver {
        const split_char_index = std.mem.indexOf(u8, input, "\n\n") orelse return error.InvalidInput;
        const buf_slice = input[0..split_char_index];
        var it = std.mem.splitBackwardsAny(u8, buf_slice, "\n");
        const num_stacks = 3;
        const operations_input = input[split_char_index + 2 ..];
        const stacks = try create_stacks(allocator, num_stacks, &it);
        const operations = try create_operations(allocator, operations_input);

        return .{ .allocator = allocator, .stacks = stacks, .operations = operations };
    }

    pub fn deinit(self: *Solver) void {
        for (self.stacks) |*stack| {
            stack.deinit();
        }
        self.allocator.free(self.stacks);
        self.allocator.free(self.operations);
    }

    pub fn print(self: *Solver) void {
        for (self.stacks) |stack| {
            for (stack.items) |item| {
                std.debug.print("{c}", .{item});
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("\n\n", .{});
    }

    pub fn solve(self: *Solver) !void {
        for (self.operations) |operation| {
            const stack_remove = &self.stacks[operation.from];
            const stack_to = &self.stacks[operation.to];

            for (1..operation.number + 1) |_| {
                const value = stack_remove.popOrNull().?;
                try stack_to.append(value);
            }
            self.print();
        }
    }
};

pub fn main() !void {
    const input = @embedFile("text.txt");
    const allocator = std.heap.page_allocator;
    var solver = Solver.init(allocator, input) catch |err| {
        std.debug.print("Error initializing solver: {}\n", .{err});
        return;
    };
    defer solver.deinit();

    solver.solve() catch |err| {
        std.debug.print("Error solving: {}\n", .{err});
        return;
    };
}
