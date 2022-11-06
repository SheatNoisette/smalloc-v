#ifndef _VALLOC_TRACKER_H_
#define _VALLOC_TRACKER_H_

#include <stdlib.h>
#include "smalloc/smalloc.h"

// Get size of the pool - 32 ko
#define POOL_SIZE 1024 * 32

// Custom malloc, free, realloc, calloc
// Here you can add your own code to track memory allocations or swap out the
// memory allocator
static char memory[POOL_SIZE];
static struct smalloc_pool pool;
static int smalloc_initialised = 0;

/* called each time we ran out of memory, in hope to get more */
size_t xpool_oom(struct smalloc_pool *spool, size_t n) {
    puts("Out of memory");
    exit(1);
}

static void xpool_ub(struct smalloc_pool *spool, const void *offender) {
    puts("Undefined behavior - Invalid address");
    exit(1);
}

void init_smalloc() {

    sm_set_ub_handler(xpool_ub);

    if (!sm_set_pool(&pool, memory, POOL_SIZE, true, xpool_oom)) {
        puts("sm_set_default_pool failed!");
        exit(1);
    }
    smalloc_initialised = 1;
}

// malloc wrapper
void *vt_alloc(size_t size)
{
    if (!smalloc_initialised) init_smalloc();
    return sm_malloc_pool(&pool, size);
}

// Free wrapper
void vt_free(void *ptr)
{
    if (!smalloc_initialised) init_smalloc();
    sm_free_pool(&pool, ptr);
}

// Realloc wrapper
void *vt_realloc(void *ptr, size_t size)
{
    if (!smalloc_initialised) init_smalloc();
    return sm_realloc_pool(&pool, ptr, size);
}

// Calloc wrapper
void *vt_calloc(size_t nmemb, size_t size)
{
    if (!smalloc_initialised) init_smalloc();
    return sm_calloc_pool(&pool, nmemb, size);
}

#endif
