#!/bin/bash

# Run the test script
~/containers-review/testdb.sh

if [ $? -eq 0 ]; then
    echo "Database is running successfully!"
else
    echo "Database verification failed."
fi
