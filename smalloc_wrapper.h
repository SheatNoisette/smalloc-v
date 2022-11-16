#ifndef _SMALLOC_WRAPPER_H_
#define _SMALLOC_WRAPPER_H_

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

#include "smalloc/smalloc.h"
#include <stdlib.h>

// Get size of the pool - 32 ko by default
#ifndef VALLOC_POOL_SIZE
#define VALLOC_POOL_SIZE (1024 * 32)
#endif

// Memory pool that will simulate the heap - 32 ko by default
// No need to zero it, malloc doesn't need it to be zeroed and calloc will do it
static char memory[VALLOC_POOL_SIZE];

// Pool configuration
static struct smalloc_pool pool;

// If the pool is initialized
static int smalloc_initialised = 0;

#endif
