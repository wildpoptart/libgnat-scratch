/*
 * Tiny stand-in for libgnat (GNAT Ada runtime).
 * A real libgnat.a / libgnat.so comes from a GNAT/GCC install, not a random download.
 */

void __gnat_runtime_initialize(void) { }
void __gnat_runtime_finalize(void) { }
void adainit(void) { }
void adafinal(void) { }
