module main

import rand

[heap]
struct CoolStruct {
mut:
	a u32
	b u32
}

fn main() {
	mut arr := []u32{}
	mut cs := CoolStruct{}

	// Push some random values
	for i := 0; i < 10; i++ {
		arr << rand.u32n(255) or { panic(err) }
	}
	// Print the array
	println(arr)

	// Add some random values to the cool_struct array
	cs.a = rand.u32n(255) or { panic(err) }
	cs.b = rand.u32n(255) or { panic(err) }

	// Print hello world
	println('Hello, world!')
}
