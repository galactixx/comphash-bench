# comphash-bench

Simple benchmarks that compares the performance of the `comphash` library's `ComptimeHashMap` against Zig's standard library `std.StaticStringMap` for string-keyed lookups.

## Overview

This package generates performance benchmarks to evaluate the lightweight `comphash` library against Zig's built-in `StaticStringMap`. The benchmarks measure lookup performance across different dataset sizes to provide insights into the relative efficiency of both implementations.

## What It Benchmarks

The benchmark suite compares:

- **`comphash.ComptimeHashMap`** - A compile-time hash map implementation from the `comphash` library
- **`std.StaticStringMap`** - Zig's standard library static string map implementation

## Benchmark Configuration

The suite tests lookup performance with datasets of varying sizes:
- **100 items**
- **1,000 items**
- **2,000 items**

Each benchmark:
- Performs 1,000,000 lookup operations per test
- Includes warmup runs to ensure consistent timing
- Measures total duration and average time per lookup
- Tests with representative keys from each dataset

## Key Features

- **Zero Runtime Allocations** - Both implementations are compile-time generated with no runtime memory allocation
- **Immutable Data Structures** - All maps are immutable, ensuring thread safety and predictable performance
- **O(1) Lookup Complexity** - Both implementations provide constant-time string key lookups
- **Comprehensive Metrics** - Detailed performance reporting including total duration, iterations, and per-call averages

## Usage

```bash
# Build and run the benchmarks
zig build run
```

## Dependencies

- **Zig 0.14.0+** - Required for build system and language features
- **comphash v0.3.0** - The library being benchmarked

## Output

The benchmark outputs detailed performance metrics for each test case:

```
================ Performance Metrics ================
Object: ComptimeHashMap.get
Size: 100 items
Iterations: 1000000
Duration: 1234567 ns
Average duration: 1 ns per call
=======================================================
```
