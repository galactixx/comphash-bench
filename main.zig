const std = @import("std");
const comphash = @import("comphash");
const items = @import("items.zig");

// Extract the items from the items.zig file
const one_hundred = items.one_hundred;
const one_thousand = items.one_thousand;
const two_thousand = items.two_thousand;

// Define the comptime hash map
const Map = comphash.ComptimeHashMap(u32, null, null, null);

// Warmup the comptime map by getting 1000 items
fn warmupComptimeMap(map: Map, key: []const u8) void {
    for (0..1000) |_| {
        _ = map.get(key);
    }
}

// Warmup the string map by getting 1000 items
fn warmupStringMap(map: std.StaticStringMap(u32), key: []const u8) void {
    for (0..1000) |_| {
        _ = map.get(key);
    }
}

// Initialize the maps with the items from the items.zig file
const map_one_hundred = blk: {
    @setEvalBranchQuota(10_000_000);
    break :blk Map.init(one_hundred);
};

const map_one_thousand = blk: {
    @setEvalBranchQuota(10_000_000);
    break :blk Map.init(one_thousand);
};

const map_two_thousand = blk: {
    @setEvalBranchQuota(20_000_000);
    break :blk Map.init(two_thousand);
};

// As a comparison, we also initialize the maps with the items
// from the items.zig file
const string_map_one_hundred = blk: {
    @setEvalBranchQuota(10_000_000);
    break :blk std.StaticStringMap(u32).initComptime(one_hundred);
};

const string_map_one_thousand = blk: {
    @setEvalBranchQuota(10_000_000);
    break :blk std.StaticStringMap(u32).initComptime(one_thousand);
};

const string_map_two_thousand = blk: {
    @setEvalBranchQuota(20_000_000);
    break :blk std.StaticStringMap(u32).initComptime(two_thousand);
};

// Display the metrics for the given object, including the object
// name, size, iterations, duration, and average duration per call.
fn displayMetrics(iterations: usize, duration: i128, obj: []const u8, size: usize) void {
    std.debug.print("================ Performance Metrics ================\n", .{});
    std.debug.print("Object: {s}\n", .{obj});
    std.debug.print("Size: {d} items\n", .{size});
    std.debug.print("Iterations: {d}\n", .{iterations});
    std.debug.print("Duration: {d} ns\n", .{duration});
    std.debug.print("Average duration: {d} ns per call\n", .{@divFloor(duration, iterations)});
    std.debug.print("=======================================================\n", .{});
}

// Benchmark the get() function for the comptime map for the given
// object, key, iterations, and size.
fn runComptimeMapBenchmark(map: Map, key: []const u8, iters: usize, size: usize) void {
    warmupComptimeMap(map, key);
    const start = std.time.nanoTimestamp();
    for (0..iters) |_| {
        _ = map.get(key);
    }
    const dur = std.time.nanoTimestamp() - start;
    displayMetrics(iters, dur, "ComptimeHashMap.get", size);
}

// Benchmark the get() function for the string map for the given
// object, key, iterations, and size.
fn runStringMapBenchmark(map: std.StaticStringMap(u32), key: []const u8, iters: usize, size: usize) void {
    warmupStringMap(map, key);
    const start = std.time.nanoTimestamp();
    for (0..iters) |_| {
        _ = map.get(key);
    }
    const dur = std.time.nanoTimestamp() - start;
    displayMetrics(iters, dur, "StaticStringMap.get", size);
}

// Benchmark the get() function for the comptime map and the string map
// for 100 and 1000 items.
pub fn main() void {
    const iters: usize = 1_000_000;

    // Benchmark get() on the 100-item map (comptime map)
    runComptimeMapBenchmark(map_one_hundred, "item50", iters, 100);

    // Benchmark get() on the 1000-item map (comptime map)
    runComptimeMapBenchmark(map_one_thousand, "item500", iters, 1000);

    // Benchmark get() on the 2000-item map (comptime map)
    runComptimeMapBenchmark(map_two_thousand, "item1000", iters, 2000);

    // Benchmark get() on the 100-item map (string map)
    runStringMapBenchmark(string_map_one_hundred, "item50", iters, 100);

    // Benchmark get() on the 1000-item map (string map)
    runStringMapBenchmark(string_map_one_thousand, "item500", iters, 1000);

    // Benchmark get() on the 2000-item map (string map)
    runStringMapBenchmark(string_map_two_thousand, "item1000", iters, 2000);
}
