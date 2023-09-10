#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

// Optional: use these functions to add debug or error prints to your application
#define DEBUG_LOG(msg,...)
//#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

void *threadfunc(void *arg) {
    struct thread_data *data = (struct thread_data *)arg;
    // Sleep for wait_to_obtain_ms milliseconds
    usleep(data->wait_to_obtain_ms * 1000 );

    // Attempt to obtain the mutex
    if (pthread_mutex_lock(&data->mutex) != 0) {
        data->thread_complete_success = false;
        pthread_exit(NULL); // Explicitly exit the thread
    }
    else
    {
    data->thread_complete_success = true;
    }	
    // Sleep for wait_to_release_ms milliseconds while holding the mutex
    usleep(data->wait_to_release_ms * 1000 );
    // Release the mutex
    if (pthread_mutex_unlock(&data->mutex) != 0) {
        data->thread_complete_success = false;
    } else {
        data->thread_complete_success = true;
    }

    // Exit the thread explicitly, returning thread_data
    pthread_exit(NULL);
}

//
bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex, int wait_to_obtain_ms, int wait_to_release_ms) {

    struct thread_data *data = malloc(sizeof(struct thread_data));
    if (data == NULL) {
        return false; // Memory allocation failed
    }
    
    // Initialize the thread-specific data
    data->mutex = *mutex; // Copy the mutex
    data->wait_to_obtain_ms = wait_to_obtain_ms;
    data->wait_to_release_ms = wait_to_release_ms;
    data->thread_complete_success = false;


    int result = pthread_create(thread, NULL, threadfunc, data);
    if (result != 0) {
        free(data);
        return false; // Thread creation failed
    }
    pthread_join(*thread, NULL); // Wait for the thread to complete
    return true;
}

