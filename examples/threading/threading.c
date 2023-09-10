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
    int rc;
    // Sleep for wait_to_obtain_ms milliseconds
    usleep( (useconds_t) data->wait_to_obtain_ms * 1000 );
    rc = pthread_mutex_lock(data->mutex);
    // Attempt to obtain the mutex
    if ( rc != 0 )
    {
        ERROR_LOG("pthread_mutex_lock failed with %d\n", rc);
    }
    // Sleep for wait_to_release_ms milliseconds while holding the mutex
    usleep(  (useconds_t) data->wait_to_release_ms * 1000 );
    // Release the mutex
    rc = pthread_mutex_unlock(data->mutex) ;
    if ( rc != 0 ) 
    {
        ERROR_LOG("pthread_mutex_unlock failed with %d\n", rc);
    }
    if (0 == rc) 
    {
        data->thread_complete_success = true;
    }
    // Exit the thread explicitly, returning thread_data
    return arg;
}

//
bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex, int wait_to_obtain_ms, int wait_to_release_ms) {

    struct thread_data *data = malloc(sizeof(struct thread_data));
    if (data == NULL) {
        return false; // Memory allocation failed
    }
    
    // Initialize the thread-specific data
    data->mutex = mutex; // Copy the mutex
    data->wait_to_obtain_ms = wait_to_obtain_ms;
    data->wait_to_release_ms = wait_to_release_ms;
    data->thread_complete_success = false;


    int result = pthread_create(thread, NULL, threadfunc, data);
    if (result != 0) {
        free(data);
        return false; // Thread creation failed
    }
    return true;
}

