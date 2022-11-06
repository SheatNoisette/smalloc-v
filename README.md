# smalloc-v

Abusing V compiler to track memory allocations. It is a proof of concept and
it is not meant to be used in production.

Using smalloc as a static memory alloc instead of malloc. This could enable
the use of V in embedded systems.

**Important**: This is a hack, and it may break your code. You have been warned.

Cloning the repo:
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

# License
This project is licensed under the MIT License - see the [LICENSE](LICENSE)
file for details
