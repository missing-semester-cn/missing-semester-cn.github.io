---
layout: lecture
title: "Program Introspection"
presenter: Anish
video:
  aspect: 62.5
  id: 74MhV-7hYzg
---

# Debugging

When printf-debugging isn't good enough: use a debugger.

Debuggers let you interact with the execution of a program, letting you do
things like:

- halt execution of the program when it reaches a certain line
- single-step through the program
- inspect values of variables
- many more advanced features

## GDB/LLDB

[GDB](https://www.gnu.org/software/gdb/) and [LLDB](https://lldb.llvm.org/).
Supports many C-like languages.

Let's look at [example.c](/2019/files/example.c). Compile with debug flags:
`gcc -g -o example example.c`.

Open GDB:

`gdb example`

Some commands:

- `run`
- `b {name of function}` - set a breakpoint
- `b {file}:{line}` - set a breakpoint
- `c` - continue
- `step` / `next` / `finish` - step in / step over / step out
- `p {variable}` - print value of variable
- `watch {expression}` - set a watchpoint that triggers when the value of the expression changes
- `rwatch {expression}` - set a watchpoint that triggers when the value is read
- `layout`

## PDB

[PDB](https://docs.python.org/3/library/pdb.html) is the Python debugger.

Insert `import pdb; pdb.set_trace()` where you want to drop into PDB, basically
a hybrid of a debugger (like GDB) and a Python shell.

## Web browser Developer Tools

Another example of a debugger, this time with a graphical interface.

# strace

Observe system calls a program makes: `strace {program}`.

# Profiling

Types of profiling: CPU, memory, etc.

Simplest profiler: `time`.

## Go

Run test code with CPU profiler: `go test -cpuprofile=cpu.out`

Analyze profile: `go tool pprof -web cpu.out`

Run test code with Memory profiler: `go test -memprofile=mem.out`

Analyze profile: `go tool pprof -web mem.out`

## Perf

Basic performance stats: `perf stat {command}`

Run a program with the profiler: `perf record {command}`

Analyze profile: `perf report`
