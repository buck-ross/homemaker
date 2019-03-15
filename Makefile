# Declare build variables:
SHELL=/bin/bash
TARGET=target
TAR_OPTS=-zv --owner=0 --group=0

# List all targets:
.PHONY: all clean

# Define a target to build all packages:
all: dir $(TARGET)/homemaker.tar.gz

# Compile "homemaker.tar.gz":
$(TARGET)/homemaker.tar.gz: homemaker.sh .homemaker.d
	tar $(TAR_OPTS) -cf $(TARGET)/homemaker.tar.gz \
		homemaker.sh \
		.homemaker.d

# Define a target to create the target folder:
dir:
	if [ ! -d $(TARGET) ]; then mkdir -v $(TARGET); fi

# Define a target to clean up all builds:
clean:
	if [ -d $(TARGET) ]; then rm -rv $(TARGET); fi

#  vim: set ts=4 sw=4 tw=0 noet :
