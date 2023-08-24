#include <stdio.h>
#include <stdbool.h>
#include <stdarg.h>
#include <stdlib.h>
#include <unistd.h> // Include this header for fork and execv
#include <sys/wait.h> // Include this header for waitpid
#include <fcntl.h> // Include this header for file-related flags
#include <string.h> // Include this header for strerror

bool do_system(const char *command);

bool do_exec(int count, ...);

bool do_exec_redirect(const char *outputfile, int count, ...);
