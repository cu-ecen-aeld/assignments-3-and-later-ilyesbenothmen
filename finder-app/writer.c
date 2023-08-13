#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>

int main(int argc, char *argv[]) {
    openlog(NULL, LOG_PID, LOG_USER);

    // Check if the correct number of arguments is provided
    if (argc != 3) {
        syslog(LOG_ERR, "Usage: %s <writefile> <writestr>", argv[0]);
        return 1;
    }

    // Open the file for writing
    FILE *file = fopen(argv[1], "w");
    
    if (file == NULL) {
        perror("Error opening file");
        syslog(LOG_ERR, "Error opening file: %m");
        return 1;
    }
    
    // Write the message to the file
    if (fprintf(file, "%s\n", argv[2]) < 0) {
        perror("Error writing to file");
        syslog(LOG_ERR, "Error writing to file: %m");
        fclose(file);
        return 1;
    }
    
    // Close the file
    fclose(file);

    // Log the successful message using syslog with LOG_DEBUG level
    syslog(LOG_DEBUG, "Writing \"%s\" to \"%s\"", argv[2], argv[1]);

    closelog();
    
    printf("Message written to the file successfully.\n");
    
    return 0;
}

