# smalloc-v

Abusing V compiler to add static memory allocations. It is a proof of concept and
it is not meant to be used in production.

Using smalloc as a static memory alloc instead of malloc. This could enable
the use of V in embedded systems.

**Important**: This is a hack, and it may break your code. You have been warned.
As this is experimental and modify the behavior of the generated C code, it
won't be pushed to vpm.

```bash
$ git clone https://github.com/sheatnoisette/smalloc-v.git
$ cd smalloc-v
$ git submodule update --init --recursive
```

## Todo

- [x] Use smalloc
- [ ] Simplify the code
- [ ] Merge smalloc_wrapper.h into a simple .c.v file

## Demo

A simple demo is provided.
```bash
# For the simple demo
$ make && ./smalloc_demo

# Track every allocation
$ DEBUG=1 make clean all && ./smalloc_demo
```

A sample Dockerfile is provided to build the demo in a container.
```bash
$ docker build -f Dockerfile -t v-linux:latest .
$ docker run -it --volume=$(pwd):/work/ --workdir=/work/ --rm v-linux:latest
```

## Integration into a project

To use smalloc in your project, you need to add the following files to your
project:
- `smalloc_wrapper.h`,
- `smalloc.c.v`,
- The content of the `smalloc` folder.

You don't need to modify your code, but you need to add the following line to
your Makefile/build system to avoid conflict with the integrated garbage
collector:
```bash
$ v -gc none -autofree run .
```
V autofree is recommended to avoid running out of memory, but not mandatory as
it is in beta currently. You might run out of memory if you don't use it.

You can configure the size of the static memory pool by modifying the
`SMALLOC_POOL_SIZE` macro in `smalloc_wrapper.h` or by overriding it in your
VFLAGS:
```bash
# 32 ko of static memory pool
$ v -gc none -autofree -cflags -DVALLOC_POOL_SIZE=32000 run .
```
As of now, the default value is 32 ko. 12 Ko is the bare minimum amount of
memory to run a basic V program. Increase the value if you need more memory.
Please note this is not a fit for all solution, memory fragmentation can happen
and may lead to unexpected behavior or a crash.

# License
This project is licensed under the MIT License - see the [LICENSE](LICENSE)
file for details.

This project is based on a modified version of the
[smalloc](https://github.com/electrorys/smalloc) project by Andrey Rys and on
[VAllocTracker](https://github.com/SheatNoisette/VAllocTracker).
