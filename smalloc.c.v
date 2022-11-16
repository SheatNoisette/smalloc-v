module main

/*******************************************************************************
 MIT License

 Copyright (c) 2022 SheatNoisette

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
*******************************************************************************/

// Header definitions
fn C.vt_alloc(int) voidptr
fn C.vt_free(voidptr)
fn C.vt_realloc(voidptr, int) voidptr
fn C.vt_calloc(int, int) voidptr

struct C.smalloc_pool {}

type FnUndefinedBehavior = fn (&C.smalloc_pool, voidptr)
type FnOutOfMemory = fn (&C.smalloc_pool, u32)

// Get access to static variables
#define _extern_get_pool() &pool
fn C._extern_get_pool() &C.smalloc_pool
#define _extern_smalloc_initialised() smalloc_initialised
fn C._extern_smalloc_initialised() int
#define _extern_smalloc_initialised_set(x) smalloc_initialised = x
fn C._extern_smalloc_initialised_set(int)
#define _extern_get_memory_ptr() memory
fn C._extern_get_memory_ptr() voidptr

fn C.init_smalloc()

// Smalloc definitions
fn C.sm_free_pool(&C.smalloc_pool, voidptr)
fn C.sm_malloc_pool(&C.smalloc_pool, u32) voidptr
fn C.sm_calloc_pool(&C.smalloc_pool, u32, u32) voidptr
fn C.sm_realloc_pool(&C.smalloc_pool, voidptr, u32) voidptr
fn C.sm_set_ub_handler(FnUndefinedBehavior)
fn C.sm_set_pool(&C.smalloc_pool, voidptr, u32, int, FnOutOfMemory) int

// C library functions
fn C.puts(&u8) int
fn C.putchar(byte)

// Every malloc call will be replaced with a call to vt_alloc, this is to avoid
// that the preprocessor overwrites the malloc calls. See this as a passthrough.
#include "smalloc_wrapper.h"
#flag -I @VROOT/

// Include smalloc
#flag -I @VROOT/smalloc/
#flag @VROOT/smalloc/smalloc.o

// Override the malloc calls
#define malloc(size) custom_malloc(size, __LINE__)
#define free(ptr) custom_free(ptr, __LINE__)
#define realloc(ptr, size) custom_realloc(ptr, size, __LINE__)
#define calloc(n, size) custom_calloc(n, size, __LINE__)

// ----------------------------
// Custom malloc calls
// ----------------------------

fn pool_out_of_memory(pool &C.smalloc_pool, size u32) {
	C.puts(c"Out of memory")
}

fn pool_unexpected_behavior(poll &C.smalloc_pool, adress voidptr) {
	C.puts(c"Unexpected behavior - invalid address")
}

fn init_smalloc() {
	C.sm_set_ub_handler(pool_unexpected_behavior)

	set_pool := C.sm_set_pool(C._extern_get_pool(), C._extern_get_memory_ptr(), C.VALLOC_POOL_SIZE, 1, pool_out_of_memory)

	if set_pool != 0 {
		C.puts(c"Failed to set pool")
		C.exit(1)
	}
	C._extern_smalloc_initialised_set(1)
}

[export: 'custom_malloc']
[markused]
fn custom_malloc(size int, line int) voidptr {
	$if debug {
		C.puts(c'> malloc {')
		C.puts(c' size: ')
		print_number_noalloc(u64(size))
		C.puts(c',line: ')
		print_number_noalloc(u64(line))
		C.puts(c'};')
	}

	if C._extern_smalloc_initialised() == 0 {
		init_smalloc()
	}

	return C.sm_malloc_pool(C._extern_get_pool(), u32(size))
}

[export: 'custom_free']
[markused]
fn custom_free(ptr voidptr, line int) {
	$if debug {
		C.puts(c'< freeing {')
		C.puts(c' ptr: ')
		print_number_noalloc(u64(ptr))
		C.puts(c',line: ')
		print_number_noalloc(u64(line))
		C.puts(c'};')
	}

	// Smalloc has not been initialised yet, initialise it
	if C._extern_smalloc_initialised() == 0 {
		init_smalloc()
	}

	C.sm_free_pool(C._extern_get_pool(), ptr)
}

[export: 'custom_realloc']
[markused]
fn custom_realloc(ptr voidptr, size int, line int) voidptr {
	$if debug {
		C.puts(c'> realloc {')
		C.puts(c' ptr: ')
		print_number_noalloc(u64(ptr))
		C.puts(c',size: ')
		print_number_noalloc(u64(size))
		C.puts(c',line: ')
		print_number_noalloc(u64(line))
		C.puts(c'};')
	}

	// Smalloc has not been initialised yet, initialise it
	if C._extern_smalloc_initialised() == 0 {
		init_smalloc()
	}

	return C.sm_realloc_pool(C._extern_get_pool(), ptr, size)
}

[export: 'custom_calloc']
[markused]
fn custom_calloc(n int, size int, line int) voidptr {
	$if debug {
		C.puts(c'> calloc {')
		C.puts(c' n: ')
		print_number_noalloc(u64(n))
		C.puts(c',size: ')
		print_number_noalloc(u64(size))
		C.puts(c',line: ')
		print_number_noalloc(u64(line))
		C.puts(c'};')
	}

	if C._extern_smalloc_initialised() == 0 {
		init_smalloc()
	}

	buffer := C.sm_calloc_pool(C._extern_get_pool(), n, size)

	if buffer == 0 {
		$if debug {
			C.puts(c'calloc failed!')
		}
		return 0
	}

	$if debug {
		C.puts(c'> got buffer:')
		print_number_noalloc(u64(buffer))
	}

	return buffer
}

// ----------------------------
// Simples functions to print without using the heap
// ----------------------------

// Print without allocating memory a string
fn print_noalloc(str &u8) {
	unsafe {
		for i := 0; str[i] != 0; i++ {
			C.putchar(str[i])
		}
	}
}

// String a number without allocating memory
fn print_number_noalloc(number u64) {
	mut i := 0
	mut digits := [20]u8{}
	mut n := number

	if n == 0 {
		C.puts(c'0')
		return
	}

	for n > 0 {
		digits[i] = u8(n % 10) + u8(`0`)
		n /= 10
		i++
	}
	for i > 0 {
		i--
		C.putchar(digits[i])
	}
	C.putchar(u8(`\n`))
}
