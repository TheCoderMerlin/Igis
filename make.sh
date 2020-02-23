#!/bin/bash
CONFIG=${1:-debug}

if [[ "$CONFIG" =~ ^(debug|release)$ ]]; then
    swift build -c $CONFIG
else
    # Terminate on error after message
    echo "Argument specified must be either 'debug' or 'release'"
    exit 1;
fi
