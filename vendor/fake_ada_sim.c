/*
 * Stand-in for Ada object code that would live inside a real libsim.a.
 *
 * Real Ada units call into the GNAT runtime (libgnat) for elaboration,
 * exceptions, memory, etc. Here we only reference a couple of typical
 * runtime entry points so linking without -lgnat fails the same way.
 */

#include "sim_api.h"

/* Symbols normally provided by libgnat / the Ada RTS. */
extern void __gnat_runtime_initialize(void);
extern void __gnat_runtime_finalize(void);
extern void adainit(void);
extern void adafinal(void);

void sim_init(void)
{
    __gnat_runtime_initialize();
    adainit();
}

int sim_add(int a, int b)
{
    return a + b;
}

void sim_shutdown(void)
{
    adafinal();
    __gnat_runtime_finalize();
}
