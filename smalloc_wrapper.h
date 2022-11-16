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
#define VALLOC_POOL_SIZE 1024 * 32
#endif

// Custom malloc, free, realloc, calloc
// Here you can add your own code to track memory allocations or swap out the
// memory allocator
static char memory[VALLOC_POOL_SIZE];
static struct smalloc_pool pool;
static int smalloc_initialised = 0;

/* called each time we ran out of memory, in hope to get more */
size_t xpool_oom(struct smalloc_pool *spool, size_t n)
{
    puts("Out of memory");
    exit(1);
}

static void xpool_ub(struct smalloc_pool *spool, const void *offender)
{
    puts("Undefined behavior - Invalid address");
    exit(1);
}

void init_smalloc()
{

    sm_set_ub_handler(xpool_ub);

    if (!sm_set_pool(&pool, memory, VALLOC_POOL_SIZE, true, xpool_oom))
    {
        puts("sm_set_default_pool failed!");
        exit(1);
    }
    smalloc_initialised = 1;
}

// malloc wrapper
void *vt_alloc(size_t size)
{
    if (!smalloc_initialised)
        init_smalloc();
    return sm_malloc_pool(&pool, size);
}

// Free wrapper
void vt_free(void *ptr)
{
    if (!smalloc_initialised)
        init_smalloc();
    sm_free_pool(&pool, ptr);
}

// Realloc wrapper
void *vt_realloc(void *ptr, size_t size)
{
    if (!smalloc_initialised)
        init_smalloc();
    return sm_realloc_pool(&pool, ptr, size);
}

// Calloc wrapper
void *vt_calloc(size_t nmemb, size_t size)
{
    if (!smalloc_initialised)
        init_smalloc();
    return sm_calloc_pool(&pool, nmemb, size);
}

#endif
