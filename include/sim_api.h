/* Public C API for the Ada-backed simulation library (libsim.a). */
#ifndef SIM_API_H
#define SIM_API_H

#ifdef __cplusplus
extern "C" {
#endif

/* Must be called once before any other sim_* function.
 * On real Ada libraries this elaborates Ada packages (via libgnat). */
void sim_init(void);

/* Example API used by main / tests. */
int  sim_add(int a, int b);
void sim_shutdown(void);

#ifdef __cplusplus
}
#endif

#endif /* SIM_API_H */
