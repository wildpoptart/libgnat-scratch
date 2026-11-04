#include <stdio.h>
#include <stdlib.h>
#include "sim_api.h"

static void expect_eq(const char *name, int got, int want)
{
    if (got != want) {
        fprintf(stderr, "FAIL %s: got %d want %d\n", name, got, want);
        exit(1);
    }
    printf("PASS %s\n", name);
}

int main(void)
{
    sim_init();
    expect_eq("sim_add zero", sim_add(0, 0), 0);
    expect_eq("sim_add pos",  sim_add(10, 32), 42);
    expect_eq("sim_add neg",  sim_add(-1, 1), 0);
    sim_shutdown();
    printf("all tests passed\n");
    return 0;
}
