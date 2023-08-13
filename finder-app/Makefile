# Default target
.PHONY: all
all: writer

# Cross-compiler prefix (override with CROSS_COMPILE=aarch64-none-linux-gnu-)
CROSS_COMPILE ?=

# Compiler and flags
CC = $(CROSS_COMPILE)gcc
CFLAGS = -Wall -Wextra

# Source files and object files
SRCS = writer.c
OBJS = $(SRCS:.c=.o)

# Output binary
TARGET = writer

# Build the application
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS)

# Clean target
.PHONY: clean
clean:
	rm -f $(TARGET) $(OBJS)

