/*
 * Simple program that generates a core dump for testing crash probe. Crash
 * test expects crash.c to be compiled.
 *
 * to compile backtrace for parsing test: gcc -g backtrace.c -o crash-debug-info.out
 */

#include <stdlib.h>

void crashing_function() {
    abort();
}

int main() {
    crashing_function();
    return 0;
}
