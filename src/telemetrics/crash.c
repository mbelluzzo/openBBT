/*
 * Simple program that generates a core dump for testing crash probe. Crash
 * test expects crash.c to be compiled.
 *
 * to compile crash use: gcc -nostdlib crash.c -o crash.out
 *
 */
_start(void){ *(char *)0 = 0 ; }
