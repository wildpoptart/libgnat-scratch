#include <stdio.h>
#include "sim_api.h"

int main(void)
{
    sim_init();
    printf("sim_add(2, 3) = %d\n", sim_add(2, 3));
    sim_shutdown();
    return 0;
}
